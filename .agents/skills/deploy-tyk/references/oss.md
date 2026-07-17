# tyk-oss Variant

Open-source Tyk Gateway — no Dashboard, no license required.

## Components

- Gateway
- Optional: Pump, Operator

## Dependencies

- Redis (required)
- No PostgreSQL or MongoDB needed

## Required Credentials

- None (no license needed for gateway)
- Optional: `--license-operator` if enabling Tyk Operator

## Chart Name

- Local: `./tyk-oss`
- Remote: `tyk-helm/tyk-oss`

## Helm Values

```yaml
global:
  redis:
    addrs:
      - tyk-redis-master.tyk.svc:6379
    pass: "<REDIS_PASS>"
  components:
    pump: false
    operator: false
```

## Post-Install

```bash
# Port-forward gateway
kubectl port-forward -n tyk svc/gateway-svc-tyk-oss-tyk-gateway 8080:8080

# Test
curl localhost:8080/hello
```
