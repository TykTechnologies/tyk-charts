## Tyk Control Plane

This Helm chart deploys the Tyk Control Plane in your Kubernetes cluster. For detailed documentation and a quick start guide, please visit the [Tyk Official Docs](https://tyk.io/docs/product-stack/tyk-charts/overview/) site.

### Installation
To install the Tyk Control Plane using this Helm chart, follow the instructions provided in the Tyk Official Docs:
- [Tyk Control Plane Installation](https://tyk.io/docs/product-stack/tyk-charts/tyk-control-plane-chart/#tyk-control-plane-installations)
- [Setup MDCB Control Plane](https://tyk.io/docs/tyk-multi-data-centre/setup-controller-data-centre/)

### Configuration
For configuration options and customization, refer to the Tyk Official Docs site.
- [Tyk Control Plane Configuration](https://tyk.io/docs/product-stack/tyk-charts/tyk-control-plane-chart/#configuration)

### Upgrade notes
The `runAsUser` defaults have been removed from the pod- and container-level security contexts while
`runAsNonRoot: true` is retained, so kubelet now relies on the image's `USER` directive.

This chart's default images are unchanged (the gateway stays on `tykio/tyk-gateway-ee:v5.13.1`, which runs as
`USER 65532`), so a default install is unaffected. If you pin your own image tags, a tag whose image has no
numeric `USER` will fail kubelet admission on `helm upgrade`. See
[Upgrade notes](../tyk-stack/README.md#upgrade-notes) for how to check your image, and for the
`securityContext.enabled: false` opt-out for OpenShift.

