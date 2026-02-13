#!/usr/bin/env bash
set -euo pipefail

# Deploy Tyk to Kubernetes
# Supports variants: stack, oss, data-plane, control-plane

NAMESPACE="tyk"
VARIANT=""
CHART_PATH=""
VALUES_FILE=""
RELEASE_NAME=""
LICENSE_DASHBOARD=""
LICENSE_OPERATOR=""
MDCB_CONNECTION_STRING=""
MDCB_ORG_ID=""
MDCB_API_KEY=""
MDCB_GROUP_ID=""
SKIP_DEPS=false
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $0 --variant <stack|oss|data-plane|control-plane> [OPTIONS]

Deploy Tyk to Kubernetes with required dependencies.

Variants:
  stack           Full platform (Dashboard, Gateway, Pump, Operator)
  oss             Open-source Gateway only (no license required)
  data-plane      Worker gateway connecting to remote MDCB control plane
  control-plane   Management cluster for multi-DC (MDCB) deployments

Options:
  --variant <name>              Deployment variant (required)
  --namespace <ns>              Kubernetes namespace (default: tyk)
  --release-name <name>         Helm release name (default: tyk-<variant>)
  --chart-path <path>           Path to local chart directory
  --values-file <file>          Custom values.yaml override file
  --skip-deps                   Skip Redis and PostgreSQL installation
  --dry-run                     Print commands without executing
  -h, --help                    Show this help message

Variant-specific options:
  --license-dashboard <key>     Dashboard license (stack, control-plane)
  --license-operator <key>      Operator license (stack, control-plane, oss)
  --mdcb-connection-string <s>  MDCB connection string (data-plane)
  --mdcb-org-id <id>            MDCB org ID (data-plane)
  --mdcb-api-key <key>          MDCB API key (data-plane)
  --mdcb-group-id <id>          MDCB group ID (data-plane, optional)
EOF
  exit 0
}

log() { echo "==> $*"; }
err() { echo "ERROR: $*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] $*"
  else
    "$@"
  fi
}

# Validate a component's health endpoint via port-forward.
# Usage: check_endpoint <label> <service> <svc-port> <path> [<expected-json-field>]
# Returns 0 on success, 1 on failure.
check_endpoint() {
  local label="$1" svc="$2" svc_port="$3" path="$4" expected="${5:-status}"
  local local_port pf_pid response

  # Pick a random local port in the ephemeral range
  local_port=$(( (RANDOM % 10000) + 30000 ))

  log "Validating $label → $svc:$svc_port$path ..."

  kubectl port-forward -n "$NAMESPACE" "svc/$svc" "${local_port}:${svc_port}" &>/dev/null &
  pf_pid=$!

  # Give port-forward time to establish
  sleep 3

  local attempts=0 max_attempts=10
  while [ $attempts -lt $max_attempts ]; do
    response=$(curl -sf "http://localhost:${local_port}${path}" 2>/dev/null || true)
    if [ -n "$response" ] && echo "$response" | grep -q "\"${expected}\""; then
      kill "$pf_pid" 2>/dev/null; wait "$pf_pid" 2>/dev/null || true
      log "  ✓ $label is healthy"
      return 0
    fi
    attempts=$((attempts + 1))
    sleep 2
  done

  kill "$pf_pid" 2>/dev/null; wait "$pf_pid" 2>/dev/null || true
  echo "WARN: $label health check failed after ${max_attempts} attempts" >&2
  if [ -n "$response" ]; then
    echo "  Last response: $response" >&2
  else
    echo "  No response received" >&2
  fi
  return 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --variant) VARIANT="$2"; shift 2 ;;
    --namespace) NAMESPACE="$2"; shift 2 ;;
    --release-name) RELEASE_NAME="$2"; shift 2 ;;
    --chart-path) CHART_PATH="$2"; shift 2 ;;
    --values-file) VALUES_FILE="$2"; shift 2 ;;
    --license-dashboard) LICENSE_DASHBOARD="$2"; shift 2 ;;
    --license-operator) LICENSE_OPERATOR="$2"; shift 2 ;;
    --mdcb-connection-string) MDCB_CONNECTION_STRING="$2"; shift 2 ;;
    --mdcb-org-id) MDCB_ORG_ID="$2"; shift 2 ;;
    --mdcb-api-key) MDCB_API_KEY="$2"; shift 2 ;;
    --mdcb-group-id) MDCB_GROUP_ID="$2"; shift 2 ;;
    --skip-deps) SKIP_DEPS=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) err "Unknown option: $1" ;;
  esac
done

# Validate variant
case "$VARIANT" in
  stack|oss|data-plane|control-plane) ;;
  "") err "--variant is required. Choose: stack, oss, data-plane, control-plane" ;;
  *) err "Unknown variant: $VARIANT. Choose: stack, oss, data-plane, control-plane" ;;
esac

# Set default release name
if [ -z "$RELEASE_NAME" ]; then
  RELEASE_NAME="tyk-$VARIANT"
fi

# Determine what this variant needs
NEEDS_POSTGRES=false
NEEDS_LICENSE=false
NEEDS_MDCB=false

case "$VARIANT" in
  stack|control-plane)
    NEEDS_POSTGRES=true
    NEEDS_LICENSE=true
    ;;
  data-plane)
    NEEDS_MDCB=true
    ;;
  oss)
    ;;
esac

# Validate variant-specific requirements
if [ "$NEEDS_LICENSE" = true ] && [ -z "$LICENSE_DASHBOARD" ]; then
  err "--license-dashboard is required for variant '$VARIANT'"
fi

if [ "$NEEDS_MDCB" = true ]; then
  [ -z "$MDCB_CONNECTION_STRING" ] && err "--mdcb-connection-string is required for variant 'data-plane'"
  [ -z "$MDCB_ORG_ID" ] && err "--mdcb-org-id is required for variant 'data-plane'"
  [ -z "$MDCB_API_KEY" ] && err "--mdcb-api-key is required for variant 'data-plane'"
fi

# Resolve chart name for remote repo
REMOTE_CHART="tyk-helm/tyk-$VARIANT"
# For local path, default to ./<variant-dir> if not provided
if [ -z "$CHART_PATH" ]; then
  LOCAL_CHART=""
else
  LOCAL_CHART="$CHART_PATH"
fi

# --- Deployment starts ---

# Step 1: Create namespace
log "Creating namespace '$NAMESPACE'..."
run kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | run kubectl apply -f -

if [ "$SKIP_DEPS" = false ]; then
  # Step 2: Install Redis (all variants need it)
  log "Adding Bitnami Helm repo..."
  run helm repo add bitnami https://charts.bitnami.com/bitnami
  run helm repo update

  log "Installing Redis..."
  run helm install tyk-redis bitnami/redis -n "$NAMESPACE" \
    --set "replica.replicaCount=0" \
    --wait --timeout 300s

  # Step 3: Install PostgreSQL (only for stack/control-plane)
  if [ "$NEEDS_POSTGRES" = true ]; then
    log "Installing PostgreSQL..."
    run helm install tyk-postgres bitnami/postgresql -n "$NAMESPACE" \
      --set "auth.database=tyk_analytics" \
      --version 12.12.10 \
      --set "image.repository=bitnamilegacy/postgresql" \
      --wait --timeout 300s
  fi
fi

# Step 4: Retrieve passwords
log "Retrieving Redis password..."
if [ "$DRY_RUN" = true ]; then
  REDIS_PASS="<redis-password>"
  echo "[DRY RUN] Would retrieve password from secret tyk-redis"
else
  REDIS_PASS=$(kubectl get secret --namespace "$NAMESPACE" tyk-redis \
    -o jsonpath="{.data.redis-password}" | base64 -d)
fi

POSTGRES_PASS=""
if [ "$NEEDS_POSTGRES" = true ]; then
  log "Retrieving PostgreSQL password..."
  if [ "$DRY_RUN" = true ]; then
    POSTGRES_PASS="<postgres-password>"
    echo "[DRY RUN] Would retrieve password from secret tyk-postgres-postgresql"
  else
    POSTGRES_PASS=$(kubectl get secret --namespace "$NAMESPACE" tyk-postgres-postgresql \
      -o jsonpath="{.data.postgres-password}" | base64 -d)
  fi
fi

# Step 5: Build helm args based on variant
log "Installing tyk-$VARIANT as '$RELEASE_NAME'..."

HELM_ARGS=(
  --set "global.redis.addrs={tyk-redis-master.$NAMESPACE.svc:6379}"
  --set "global.redis.pass=$REDIS_PASS"
)

case "$VARIANT" in
  stack|control-plane)
    HELM_ARGS+=(
      --set "global.license.dashboard=$LICENSE_DASHBOARD"
      --set "global.components.operator=true"
      --set "global.storageType=postgres"
      --set "global.postgres.host=tyk-postgres-postgresql.$NAMESPACE.svc"
      --set "global.postgres.port=5432"
      --set "global.postgres.user=postgres"
      --set "global.postgres.password=$POSTGRES_PASS"
      --set "global.postgres.database=tyk_analytics"
      --set "global.postgres.sslmode=disable"
    )
    if [ -n "$LICENSE_OPERATOR" ]; then
      HELM_ARGS+=(--set "global.license.operator=$LICENSE_OPERATOR")
    fi
    ;;
  data-plane)
    HELM_ARGS+=(
      --set "global.remoteControlPlane.enabled=true"
      --set "global.remoteControlPlane.connectionString=$MDCB_CONNECTION_STRING"
      --set "global.remoteControlPlane.orgId=$MDCB_ORG_ID"
      --set "global.remoteControlPlane.userApiKey=$MDCB_API_KEY"
      --set "global.remoteControlPlane.useSSL=true"
    )
    if [ -n "$MDCB_GROUP_ID" ]; then
      HELM_ARGS+=(--set "global.remoteControlPlane.groupID=$MDCB_GROUP_ID")
    fi
    ;;
  oss)
    if [ -n "$LICENSE_OPERATOR" ]; then
      HELM_ARGS+=(
        --set "global.components.operator=true"
        --set "global.license.operator=$LICENSE_OPERATOR"
      )
    fi
    ;;
esac

if [ -n "$VALUES_FILE" ]; then
  HELM_ARGS+=(-f "$VALUES_FILE")
fi

if [ -n "$LOCAL_CHART" ]; then
  log "Rebuilding chart dependencies..."
  run helm dependency build "$LOCAL_CHART"
  run helm install "$RELEASE_NAME" "$LOCAL_CHART" -n "$NAMESPACE" "${HELM_ARGS[@]}" --wait --timeout 600s
else
  run helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
  run helm repo update
  run helm install "$RELEASE_NAME" "$REMOTE_CHART" -n "$NAMESPACE" "${HELM_ARGS[@]}" --wait --timeout 600s
fi

log "Tyk ($VARIANT) deployed successfully as '$RELEASE_NAME' in namespace '$NAMESPACE'!"

# --- Step 6: Validate component health ---
if [ "$DRY_RUN" = true ]; then
  log "[DRY RUN] Would validate component health endpoints"
else
  log ""
  log "Validating deployment health..."
  VALIDATION_FAILED=false

  # Gateway — all variants
  GW_SVC="gateway-svc-${RELEASE_NAME}-tyk-gateway"
  if ! check_endpoint "Gateway" "$GW_SVC" 8080 "/hello" "status"; then
    VALIDATION_FAILED=true
  fi

  # Dashboard — stack and control-plane
  case "$VARIANT" in
    stack|control-plane)
      DASH_SVC="dashboard-svc-${RELEASE_NAME}-tyk-dashboard"
      if ! check_endpoint "Dashboard" "$DASH_SVC" 3000 "/hello" "status"; then
        VALIDATION_FAILED=true
      fi
      ;;
  esac

  # MDCB — control-plane only
  case "$VARIANT" in
    control-plane)
      MDCB_SVC="mdcb-svc-${RELEASE_NAME}-tyk-mdcb"
      if ! check_endpoint "MDCB" "$MDCB_SVC" 8181 "/liveness" "status"; then
        VALIDATION_FAILED=true
      fi
      ;;
  esac

  log ""
  if [ "$VALIDATION_FAILED" = true ]; then
    echo "WARN: One or more health checks failed. Check logs with:" >&2
    echo "  kubectl logs -n $NAMESPACE -l app=tyk-gateway --tail=50" >&2
    echo "  kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'" >&2
  else
    log "All components healthy!"
  fi
fi

log ""
log "Useful commands:"
log "  kubectl get pods -n $NAMESPACE"
log "  kubectl get svc -n $NAMESPACE"
