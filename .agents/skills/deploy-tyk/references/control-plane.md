# tyk-control-plane Variant

Tyk control plane for multi-data-center (MDCB) deployments. Manages remote data-plane gateways.

## Components

- Dashboard, Gateway, Bootstrap
- Optional: Pump, Operator, Dev Portal

## Dependencies

- Redis (required)
- PostgreSQL (required, default) or MongoDB

## Required Credentials

- `--license-dashboard` — Tyk Dashboard license key (must include MDCB capability)
- `--license-operator` — Tyk Operator license key (if operator enabled)

## Chart Name

- Local: `./tyk-control-plane`
- Remote: `tyk-helm/tyk-control-plane`

## Helm Values

```yaml
global:
  license:
    dashboard: "<DASHBOARD_LICENSE>"
    operator: "<OPERATOR_LICENSE>"
  components:
    operator: false
    pump: false
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
kubectl port-forward -n tyk svc/dashboard-svc-tyk-control-plane-tyk-dashboard 3000:3000
```

## Notes

- After deploying, configure MDCB settings in the Dashboard to allow data-plane gateways to connect
- Data-plane gateways use the `tyk-data-plane` chart and connect via MDCB connection string
