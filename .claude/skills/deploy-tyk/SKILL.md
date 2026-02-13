---
name: deploy-tyk
description: Deploy Tyk API Management to Kubernetes using Helm charts. Supports all variants — tyk-stack (full platform), tyk-oss (open-source gateway), tyk-data-plane (worker gateway for MDCB), and tyk-control-plane (MDCB management cluster). Use when the user asks to "deploy tyk", "install tyk", "set up tyk stack/oss/hybrid", "deploy tyk charts", "helm install tyk", or any variation of deploying/installing Tyk with its dependencies. Also triggers for teardown/uninstall requests.
---

# Deploy Tyk

Deploy any Tyk variant to Kubernetes with its required dependencies.

## Variant Selection

Ask the user which variant they need if not specified:

| Variant | Use Case | Dependencies | License? |
|---------|----------|-------------|----------|
| **stack** | Full platform (single DC) | Redis + PostgreSQL | Yes |
| **oss** | Open-source gateway only | Redis | No |
| **data-plane** | Worker gateway (MDCB) | Redis | No (uses remote control plane) |
| **control-plane** | Management cluster (MDCB) | Redis + PostgreSQL | Yes (with MDCB) |

For variant-specific values, helm args, and post-install steps, read the corresponding reference file:
- `references/stack.md` — tyk-stack details
- `references/oss.md` — tyk-oss details
- `references/data-plane.md` — tyk-data-plane details
- `references/control-plane.md` — tyk-control-plane details

## Automated Deployment

Run the bundled script:

```bash
# tyk-stack (full platform)
bash scripts/deploy-tyk.sh --variant stack \
  --license-dashboard "<KEY>" --license-operator "<KEY>"

# tyk-oss (open source, no license)
bash scripts/deploy-tyk.sh --variant oss

# tyk-data-plane (worker gateway)
bash scripts/deploy-tyk.sh --variant data-plane \
  --mdcb-connection-string "<CONN>" --mdcb-org-id "<ORG>" --mdcb-api-key "<KEY>"

# tyk-control-plane (MDCB management)
bash scripts/deploy-tyk.sh --variant control-plane \
  --license-dashboard "<KEY>"
```

### Common Script Options

| Flag | Default | Description |
|------|---------|-------------|
| `--variant` | (required) | stack, oss, data-plane, control-plane |
| `--namespace` | `tyk` | Kubernetes namespace |
| `--release-name` | `tyk-<variant>` | Helm release name |
| `--chart-path` | - | Local chart dir (rebuilds deps automatically) |
| `--values-file` | - | Custom values.yaml override |
| `--skip-deps` | false | Skip Redis/PostgreSQL install |
| `--dry-run` | false | Print commands without executing |

## Manual Deployment Steps

Common across all variants:

### 1. Create Namespace

```bash
kubectl create namespace tyk
```

### 2. Install Redis (all variants)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install tyk-redis bitnami/redis -n tyk --set "replica.replicaCount=0"
```

### 3. Install PostgreSQL (stack and control-plane only)

```bash
helm install tyk-postgres bitnami/postgresql -n tyk \
  --set "auth.database=tyk_analytics" \
  --version 12.12.10 \
  --set "image.repository=bitnamilegacy/postgresql"
```

### 4. Retrieve Passwords

```bash
export REDIS_PASS=$(kubectl get secret -n tyk tyk-redis \
  -o jsonpath="{.data.redis-password}" | base64 -d)

# Only for stack/control-plane:
export POSTGRES_PASS=$(kubectl get secret -n tyk tyk-postgres-postgresql \
  -o jsonpath="{.data.postgres-password}" | base64 -d)
```

### 5. Install the Chart

Read the relevant `references/<variant>.md` file for the exact helm install command and values.

When using a local chart, always rebuild dependencies first:
```bash
helm dependency build ./tyk-<variant>
```

## Teardown

```bash
helm uninstall <release-name> -n tyk
helm uninstall tyk-postgres -n tyk    # if installed
helm uninstall tyk-redis -n tyk
kubectl delete namespace tyk
```

## Troubleshooting

- **Gateway "Redis is either down or was not configured"**: Redis address mismatch. The chart defaults to `redis.{namespace}.svc:6379` but Bitnami Redis creates `tyk-redis-master.{namespace}.svc:6379`. Set `global.redis.addrs={tyk-redis-master.<namespace>.svc:6379}`.
- **Dashboard CrashLoopBackOff / "Attempting to reach KV store"**: Redis password not set. Verify `global.redis.pass` matches the Bitnami-generated password.
- **Stale chart dependencies**: When using local charts, run `helm dependency build` before install/upgrade.
- **Webhook errors after reinstall**: Delete stale webhook configs from previous releases: `kubectl get mutatingwebhookconfigurations,validatingwebhookconfigurations | grep tyk`
- **Operator CreateContainerConfigError**: Bootstrap job may still be running. Wait for it to complete, or check for missing `tyk-operator-conf` secret.
