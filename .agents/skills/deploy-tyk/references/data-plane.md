# tyk-data-plane Variant

Worker gateway that connects to a remote control plane (Tyk Cloud or self-hosted MDCB).

## Components

- Gateway (slave mode)
- Pump (enabled by default)

## Dependencies

- Redis (required)
- No PostgreSQL or MongoDB (managed by remote control plane)
- Remote MDCB control plane must be reachable

## Required Credentials

- `--mdcb-connection-string` — MDCB connection string (e.g. from Tyk Cloud Console)
- `--mdcb-org-id` — Organization ID from Dashboard
- `--mdcb-api-key` — API key of Dashboard user
- Optional: `--mdcb-group-id` — Group ID for event tracking

## Chart Name

- Local: `./tyk-data-plane`
- Remote: `tyk-helm/tyk-data-plane`

## Helm Values

```yaml
global:
  redis:
    addrs:
      - tyk-redis-master.tyk.svc:6379
    pass: "<REDIS_PASS>"
  remoteControlPlane:
    enabled: true
    connectionString: "<MDCB_CONNECTION_STRING>"
    orgId: "<MDCB_ORG_ID>"
    userApiKey: "<MDCB_API_KEY>"
    groupID: "<MDCB_GROUP_ID>"
    useSSL: true
    sslInsecureSkipVerify: true
  components:
    pump: true
```

## Post-Install

```bash
# Port-forward gateway
kubectl port-forward -n tyk svc/gateway-svc-tyk-data-plane-tyk-gateway 8080:8080

# Test
curl localhost:8080/hello
```
