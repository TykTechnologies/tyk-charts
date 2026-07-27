## Tyk Data Plane

This Helm chart deploys the Tyk Data Plane in your Kubernetes cluster. For detailed documentation and a quick start guide, please visit the [Tyk Official Docs](https://tyk.io/docs/product-stack/tyk-charts/overview/) site.

### Installation
To install the Tyk Data Plane using this Helm chart, follow the instructions provided in the Tyk Official Docs:
- [Tyk Data Plane Installation](https://tyk.io/docs/product-stack/tyk-charts/tyk-data-plane-chart/#tyk-data-plane-chart-installations)
- [Setup Hybrid Data Plane for Tyk Cloud](https://tyk.io/docs/tyk-cloud/environments-deployments/hybrid-gateways/#deploy-in-kubernetes-with-helm-chart)
- [Setup MDCB Data Plane](https://tyk.io/docs/tyk-multi-data-centre/setup-worker-data-centres/)

### Configuration
For configuration options and customization, refer to the Tyk Official Docs site.
- [Tyk Data Plane Configuration](https://tyk.io/docs/product-stack/tyk-charts/tyk-data-plane-chart/#configuration)

### Upgrade notes
The `runAsUser` defaults have been removed from the pod- and container-level security contexts while
`runAsNonRoot: true` is retained, so kubelet now relies on the image's `USER` directive.

This chart's default images are unchanged (the gateway stays on `tykio/tyk-gateway-ee:v5.13.1`, which runs as
`USER 65532`), so a default install is unaffected. If you pin your own image tags, a tag whose image has no
numeric `USER` will fail kubelet admission on `helm upgrade`. See
[Upgrade notes](../tyk-stack/README.md#upgrade-notes) for how to check your image, and for the
`securityContext.enabled: false` opt-out for OpenShift.

### Storing remote control plane credentials in Kubernetes Secrets
The remote control plane settings under `global.remoteControlPlane` can be supplied from externally managed
k8s Secrets instead of plaintext values. There are two independent mechanisms:

| Value | Covers | Secret keys read |
| --- | --- | --- |
| `global.remoteControlPlane.useSecretName` | `orgId`, `userApiKey`, `groupID` | `orgId`, `userApiKey`, `groupID` |
| `global.remoteControlPlane.connectionStringSecretName` | `connectionString` only | `connectionString`, or the key named by `connectionStringSecretKey` |

`connectionStringSecretName` is **independent of** `useSecretName` — setting one does not imply the other. This is
deliberate: an install that stores its credentials in a secret while keeping a literal `connectionString` in
`values.yaml` is a supported (and previously documented) setup, and must keep working across `helm upgrade`.

* Leave `connectionStringSecretName` unset to use the literal `global.remoteControlPlane.connectionString`.
* Set it to load `TYK_GW_SLAVEOPTIONS_CONNECTIONSTRING` via `secretKeyRef` from that Secret. The key defaults to
  `connectionString`; override it with `global.remoteControlPlane.connectionStringSecretKey`.
* The secret may be the same one referenced by `useSecretName`, or a separate one. If you point
  `connectionStringSecretName` at the `useSecretName` secret, that secret must also contain the connection string key.

```yaml
global:
  remoteControlPlane:
    enabled: true
    # orgId / userApiKey / groupID come from this secret
    useSecretName: tyk-data-plane-credentials
    # connectionString comes from this one, under key "connectionString"
    connectionStringSecretName: tyk-mdcb-connection
    # connectionStringSecretKey: connectionString
```

