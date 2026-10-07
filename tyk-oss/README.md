## Tyk Open Source

This Helm chart deploys the Tyk Open Source Gateway in your Kubernetes cluster. For detailed documentation and a quick start guide, please visit the [Tyk Official Docs](https://tyk.io/docs/product-stack/tyk-charts/overview/) site.

### Installation
To install the Tyk OSS using this Helm chart, follow the instructions provided in the Tyk Official Docs:
- [Tyk Open Source Installation](https://tyk.io/docs/product-stack/tyk-charts/tyk-oss-chart/#tyk-oss-installations)
- [Quick Start with Tyk OSS Helm Chart](https://tyk.io/docs/tyk-oss/ce-helm-chart-new/)

### Configuration
For configuration options and customization, refer to the Tyk Official Docs site.
- [Tyk Open Source Configuration](https://tyk.io/docs/product-stack/tyk-charts/tyk-oss-chart/#configuration)

### Upgrade notes
The `runAsUser` defaults have been removed from the pod- and container-level security contexts while
`runAsNonRoot: true` is retained, so kubelet now relies on the image's `USER` directive.

**This chart's default gateway image tag changes in this release**, from `v5.9.1` to `v5.13.1`, because
`docker.tyk.io/tyk-gateway/tyk-gateway:v5.9.1` runs as `USER 0` and would otherwise fail kubelet admission.
If you have pinned `gateway.image.tag` to `v5.9.1` or any other pre-`v5.13` tag, your pin is preserved and the
gateway pod **will fail to start** — see
[Upgrade notes](../tyk-stack/README.md#upgrade-notes) for how to check your image and what to do about it, plus
the `securityContext.enabled: false` opt-out for OpenShift.
