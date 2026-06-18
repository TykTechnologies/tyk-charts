#!/usr/bin/env bash
# Bump component image versions and/or chart versions in tyk-charts.
# All version arguments are optional — only specified components are updated.
# Safe to run multiple times; uses old-version anchored replacements.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --gateway VERSION        Gateway (EE) image version      e.g. 5.8.14
  --dashboard VERSION      Dashboard image version         e.g. 5.8.14
  --mdcb VERSION           MDCB image version              e.g. 2.11.0
  --pump VERSION           Pump image version              e.g. 1.15.0
  --portal VERSION         Portal image version            e.g. 1.17.1
  --operator VERSION       Operator image version          e.g. 1.4.0
  --chart-version VERSION  Helm chart version (non-operator charts)  e.g. 5.2.0
  --operator-chart VERSION Helm chart version for tyk-operator       e.g. 1.4.0
  -h, --help               Show this help

All version values should be provided WITHOUT the leading 'v'.
EOF
}

GATEWAY=""
DASHBOARD=""
MDCB=""
PUMP=""
PORTAL=""
OPERATOR=""
CHART_VERSION=""
OPERATOR_CHART_VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --gateway)           GATEWAY="$2";                shift 2 ;;
        --dashboard)         DASHBOARD="$2";              shift 2 ;;
        --mdcb)              MDCB="$2";                   shift 2 ;;
        --pump)              PUMP="$2";                   shift 2 ;;
        --portal)            PORTAL="$2";                 shift 2 ;;
        --operator)          OPERATOR="$2";               shift 2 ;;
        --chart-version)     CHART_VERSION="$2";          shift 2 ;;
        --operator-chart)    OPERATOR_CHART_VERSION="$2"; shift 2 ;;
        -h|--help)           usage; exit 0 ;;
        *)                   echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

cd "$REPO_ROOT"

# Replace the image tag that immediately follows a specific repository declaration.
# Handles both quoted ("v1.2.3") and unquoted (v1.2.3) tag styles.
# Args: repo  new_version  file [file ...]
bump_by_repo() {
    local repo="$1" new_ver="$2"
    shift 2
    local files=("$@")
    for f in "${files[@]}"; do
        perl -i -0pe \
            's|(repository: \Q'"${repo}"'\E[^\n]*\n(?:(?!\s*tag:)[^\n]*\n)*\s*tag: )("?)v[\d.]+\2|${1}${2}v'"${new_ver}"'${2}|g' \
            "$f"
    done
}

# ── Image tag bumps ──────────────────────────────────────────────────────────

if [[ -n "$GATEWAY" ]]; then
    echo "Gateway (EE): → v${GATEWAY}"
    # Component file uses docker.tyk.io registry; parent EE charts use tykio registry
    bump_by_repo "docker.tyk.io/tyk-gateway/tyk-gateway" "$GATEWAY" \
        components/tyk-gateway/values.yaml
    bump_by_repo "tykio/tyk-gateway-ee" "$GATEWAY" \
        tyk-stack/values.yaml \
        tyk-control-plane/values.yaml \
        tyk-data-plane/values.yaml
fi

if [[ -n "$DASHBOARD" ]]; then
    echo "Dashboard:    → v${DASHBOARD}"
    bump_by_repo "tykio/tyk-dashboard" "$DASHBOARD" \
        components/tyk-dashboard/values.yaml \
        tyk-stack/values.yaml \
        tyk-control-plane/values.yaml
fi

if [[ -n "$MDCB" ]]; then
    echo "MDCB:         → v${MDCB}"
    bump_by_repo "tykio/tyk-mdcb-docker" "$MDCB" \
        components/tyk-mdcb/values.yaml \
        tyk-control-plane/values.yaml
fi

if [[ -n "$PUMP" ]]; then
    echo "Pump:         → v${PUMP}"
    # Component file and tyk-oss use docker.tyk.io registry; other parent charts use tykio registry
    bump_by_repo "docker.tyk.io/tyk-pump/tyk-pump" "$PUMP" \
        components/tyk-pump/values.yaml \
        tyk-oss/values.yaml
    bump_by_repo "tykio/tyk-pump-docker-pub" "$PUMP" \
        tyk-stack/values.yaml \
        tyk-control-plane/values.yaml \
        tyk-data-plane/values.yaml
fi

if [[ -n "$PORTAL" ]]; then
    echo "Portal:       → v${PORTAL}"
    bump_by_repo "tykio/portal" "$PORTAL" \
        components/tyk-dev-portal/values.yaml \
        tyk-stack/values.yaml \
        tyk-control-plane/values.yaml
fi

if [[ -n "$OPERATOR" ]]; then
    echo "Operator:     → v${OPERATOR}"
    bump_by_repo "tykio/tyk-operator" "$OPERATOR" \
        components/tyk-operator/values.yaml \
        tyk-stack/values.yaml \
        tyk-control-plane/values.yaml \
        tyk-oss/values.yaml
fi

# ── Chart version bumps ──────────────────────────────────────────────────────

if [[ -n "$CHART_VERSION" ]]; then
    CURRENT_CHART=$(grep '^version:' tyk-stack/Chart.yaml | awk '{print $2}')
    echo "Chart version: ${CURRENT_CHART} → ${CHART_VERSION}"

    NON_OP_CHARTS=(
        components/tyk-gateway/Chart.yaml
        components/tyk-dashboard/Chart.yaml
        components/tyk-mdcb/Chart.yaml
        components/tyk-pump/Chart.yaml
        components/tyk-dev-portal/Chart.yaml
        components/tyk-bootstrap/Chart.yaml
        tyk-stack/Chart.yaml
        tyk-control-plane/Chart.yaml
        tyk-data-plane/Chart.yaml
        tyk-oss/Chart.yaml
    )
    for f in "${NON_OP_CHARTS[@]}"; do
        # Top-level chart version (no leading spaces)
        perl -i -pe "s|^(version: )\Q${CURRENT_CHART}\E|\${1}${CHART_VERSION}|" "$f"
        # Dependency versions in parent charts (4-space indent)
        perl -i -pe "s|^(    version: )\Q${CURRENT_CHART}\E|\${1}${CHART_VERSION}|" "$f"
    done
fi

if [[ -n "$OPERATOR_CHART_VERSION" ]]; then
    CURRENT_OP_CHART=$(grep '^version:' components/tyk-operator/Chart.yaml | awk '{print $2}')
    echo "Operator chart version: ${CURRENT_OP_CHART} → ${OPERATOR_CHART_VERSION}"

    # Operator component chart (may have trailing comment)
    perl -i -pe "s|^(version: )\Q${CURRENT_OP_CHART}\E(.*)?$|\${1}${OPERATOR_CHART_VERSION}\${2}|" \
        components/tyk-operator/Chart.yaml

    # Operator dependency version in parent charts
    for f in tyk-stack/Chart.yaml tyk-control-plane/Chart.yaml tyk-oss/Chart.yaml; do
        perl -i -pe "s|^(    version: )\Q${CURRENT_OP_CHART}\E|\${1}${OPERATOR_CHART_VERSION}|" "$f"
    done
fi

# ── Chart.lock regeneration ──────────────────────────────────────────────────

if [[ -n "$CHART_VERSION" || -n "$OPERATOR_CHART_VERSION" ]]; then
    if command -v helm &>/dev/null; then
        echo "Regenerating Chart.lock files..."
        for chart in tyk-stack tyk-control-plane tyk-data-plane tyk-oss; do
            echo "  helm dependency update ${chart}"
            helm dependency update "$chart" --skip-refresh 2>&1
        done
    else
        echo "Warning: helm not found — run 'helm dependency update' on each parent chart manually."
    fi
fi

echo "Done."
