# Tyk Helm Charts

This repository contains the official Helm charts for deploying Tyk API Management on Kubernetes.

## Chart Structure

**Umbrella charts** (deploy a full Tyk variant with all required components):
- `tyk-stack/` — Full platform (Gateway, Dashboard, Pump, Operator)
- `tyk-oss/` — Open-source gateway only
- `tyk-control-plane/` — MDCB management cluster
- `tyk-data-plane/` — Worker gateway for MDCB / Tyk Cloud hybrid

**Component charts** (individual components, used as sub-charts):
- `components/tyk-gateway/`
- `components/tyk-dashboard/`
- `components/tyk-pump/`
- `components/tyk-dev-portal/`
- `components/tyk-mdcb/`

## Key Commands

```bash
# Rebuild chart dependencies (required before local install/test)
helm dependency build ./tyk-stack

# Lint charts
ct lint --charts ./tyk-stack

# Run unit tests
make test

# Install from local chart
helm install tyk-stack ./tyk-stack -n tyk -f values.yaml
```

## Conventions

- Each umbrella chart has its own `Chart.yaml` listing component sub-charts as dependencies
- Global values are passed via `global.*` keys and consumed by all sub-charts
- Chart tests use the `helm-unittest` plugin (run via `make test`)
- CI uses `chart-testing` (`ct`) for lint and install validation

## Quick Deployment

Use the `/deploy-tyk` skill to interactively deploy any Tyk variant to a Kubernetes cluster with all dependencies.
