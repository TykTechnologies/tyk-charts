# tyk-stack Variant

Full Tyk API Management platform — single data center deployment.

## Components

- Gateway, Dashboard, Pump, Bootstrap
- Optional: Operator (requires cert-manager), Dev Portal

## Dependencies

- Redis (required)
- PostgreSQL (required, default) or MongoDB

## Required Credentials

- `--license-dashboard` — Tyk Dashboard license key
- `--license-operator` — Tyk Operator license key (if operator enabled)

## Chart Name

- Local: `./tyk-stack`
- Remote: `tyk-helm/tyk-stack`

## Helm Values

```yaml
global:
  license:
    dashboard: "<DASHBOARD_LICENSE>"
    operator: "<OPERATOR_LICENSE>"
  components:
    operator: true       # set false if not using operator
    pump: true
    bootstrap: true
  storageType: postgres
  redis:
    addrs:
      - tyk-redis-master.tyk.svc:6379
    pass: "<REDIS_PASS>"
  postgres:
    host: tyk-postgres-postgresql.tyk.svc
    port: 5432
    user: postgres
    password: "<POSTGRES_PASS>"
    database: tyk_analytics
    sslmode: disable
```

## Post-Install

```bash
# Get dashboard login password
kubectl get secret -n tyk tyk-dashboard-login-details \
  -o jsonpath="{.data.adminUserPassword}" | base64 -d

# Port-forward dashboard
kubectl port-forward -n tyk svc/dashboard-svc-tyk-stack-tyk-dashboard 3000:3000

# Port-forward gateway
kubectl port-forward -n tyk svc/gateway-svc-tyk-stack-tyk-gateway 8080:8080
```
