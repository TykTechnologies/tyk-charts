## Tyk Stack

This Helm chart deploys the Tyk Stack (Tyk Self-managed) in your Kubernetes cluster. For detailed documentation and a quick start guide, please visit the [Tyk Official Docs](https://tyk.io/docs/product-stack/tyk-charts/overview/) site.

### Installation
To install the Tyk Stack using this Helm chart, follow the instructions provided in the Tyk Official Docs:
- [Tyk Stack Installation](https://tyk.io/docs/product-stack/tyk-charts/tyk-stack-chart/#tyk-stack-installations)
- [Quick Start with Helm Chart and PostgreSQL](https://tyk.io/docs/deployment-and-operations/tyk-self-managed/deployment-lifecycle/installations/kubernetes/tyk-helm-tyk-stack-postgresql/)
- [Quick Start with Helm Chart and MongoDB](https://tyk.io/docs/deployment-and-operations/tyk-self-managed/deployment-lifecycle/installations/kubernetes/tyk-helm-tyk-stack-mongodb/)

### Configuration
For configuration options and customization, refer to the Tyk Official Docs site.
- [Tyk Stack Configuration](https://tyk.io/docs/product-stack/tyk-charts/tyk-stack-chart/#configuration)

### Upgrade notes

These notes apply to all of the umbrella charts in this repository (`tyk-stack`, `tyk-control-plane`,
`tyk-data-plane`, `tyk-oss`) and to the component charts they pull in.

#### Container `runAsUser` defaults removed — pinned image tags may fail to start

The `runAsUser: 1000` defaults have been removed from both the pod-level `securityContext` and the
container-level `containerSecurityContext` blocks, so that platforms such as OpenShift can assign a UID from
the namespace's allocated range via a Security Context Constraint. `runAsNonRoot: true` and `fsGroup` are
retained.

With no `runAsUser`, kubelet falls back to the `USER` directive baked into the image to decide whether the
container will run as root. **Every image these charts default to carries a numeric `USER` of 65532**, so a
default install is unaffected. The risk applies only if you pin an image tag of your own.

If you pin a tag whose image lacks a numeric `USER`, the pod fails kubelet admission on `helm upgrade` with:

```
CreateContainerConfigError: container has runAsNonRoot and image will run as root
```

Two cases fail:

* **Images with no `USER`, or `USER 0`.** For example, `docker.tyk.io/tyk-gateway/tyk-gateway:v5.9.1` runs as
  `USER 0`. See the warning on `gateway.image.tag` in [`tyk-oss/values.yaml`](../tyk-oss/values.yaml).
* **Images with a *symbolic* `USER`** (for example the distroless `nonroot` user). kubelet cannot verify a
  non-numeric user against `runAsNonRoot` and rejects the pod with `non-numeric user (nonroot), cannot verify
  user is non-root`. Tyk gateway `v5.13.0-rc1` was affected by this; the released `v5.13.1` is not.

##### Which default image tags changed in this release

Only **`tyk-oss`** changes a default image tag. The other umbrella charts were already on images with a numeric
`USER` and are unchanged.

| Chart | Default gateway image | Changed this release? |
| --- | --- | --- |
| `tyk-oss` | `docker.tyk.io/tyk-gateway/tyk-gateway:v5.13.1` | **Yes** — bumped from `v5.9.1`, which ran as `USER 0` |
| `tyk-stack` | `tykio/tyk-gateway-ee:v5.13.1` | No |
| `tyk-control-plane` | `tykio/tyk-gateway-ee:v5.13.1` | No |
| `tyk-data-plane` | `tykio/tyk-gateway-ee:v5.13.1` | No |

No other component's default image tag changes in this release. The dashboard (`tykio/tyk-dashboard:v5.13.1`),
pump (`tykio/tyk-pump-docker-pub:v1.16.0`) and MDCB (`tykio/tyk-mdcb-docker:v2.12.0`) defaults all already ran
as `USER 65532`.

If you are upgrading `tyk-oss` and had **not** overridden `gateway.image.tag`, your gateway moves from `v5.9.1`
to `v5.13.1` — review that version bump as you would any other. If you had pinned `v5.9.1` (or any other
pre-`v5.13` tag) explicitly, your pin is preserved and the gateway pod **will fail to start** until you act.

##### If you pin your own image tag

Check the image's `USER` before upgrading. Anything non-numeric or `0` needs action:

```console
$ crane config docker.tyk.io/tyk-gateway/tyk-gateway:v5.13.1 | jq -r '.config.User'
65532

$ crane config docker.tyk.io/tyk-gateway/tyk-gateway:v5.9.1 | jq -r '.config.User'
0
```

(`docker image inspect --format '{{.Config.User}}' <image>` works too, for images you have pulled locally.)

If the value is numeric and non-zero, no action is needed. Otherwise either move to a tag with a numeric
`USER`, or restore an explicit `runAsUser` on the affected component:

```yaml
tyk-gateway:
  gateway:
    containerSecurityContext:
      runAsUser: 1000
```

#### `securityContext.enabled: false` opt-out

Every pod-level and container-level security context block now accepts an `enabled` flag. Setting
`enabled: false` omits the entire rendered block from the manifest, letting the cluster inject its own defaults —
this is the supported path for OpenShift, where the SCC assigns UID, GID and fsGroup. Setting
`securityContext: {}` is **not** sufficient, because Helm deep-merges the chart's defaults back in. The `enabled`
key itself is never rendered into the manifest.

Each block is scoped independently, so you must disable each one you want omitted. The value paths are not
uniform across the component charts — note in particular that MDCB uses `podSecurityContext` for the pod level,
and the operator uses `managerPodSecurityContext` for the pod level and plain `securityContext` for the
*container* level:

| Component | Pod-level path | Container-level path |
| --- | --- | --- |
| `tyk-gateway` | `tyk-gateway.gateway.securityContext` | `tyk-gateway.gateway.containerSecurityContext` |
| `tyk-gateway` init container | — | `tyk-gateway.gateway.initContainers.setupDirectories.securityContext` |
| `tyk-dashboard` | `tyk-dashboard.dashboard.securityContext` | `tyk-dashboard.dashboard.containerSecurityContext` |
| `tyk-pump` | `tyk-pump.pump.securityContext` | `tyk-pump.pump.containerSecurityContext` |
| `tyk-mdcb` | `tyk-mdcb.mdcb.`**`podSecurityContext`** | `tyk-mdcb.mdcb.containerSecurityContext` |
| `tyk-operator` | `tyk-operator.`**`managerPodSecurityContext`** | `tyk-operator.securityContext` |
| `tyk-dev-portal` | `tyk-dev-portal.securityContext` | `tyk-dev-portal.containerSecurityContext` |
| `tyk-dev-portal` bootstrap Job | `tyk-dev-portal.bootstrapJob.securityContext` | `tyk-dev-portal.bootstrapJob.containerSecurityContext` |
| `tyk-bootstrap` Jobs | `tyk-bootstrap.bootstrap.securityContext` | `tyk-bootstrap.bootstrap.containerSecurityContext` |
| `helm test` pod | `tests.securityContext` | `tests.containerSecurityContext` |

The `tests.*` keys sit at the **umbrella chart root**, not under a component. The `helm test` pod pins
`runAsUser: 1000`, which is outside the allocated range on OpenShift, so `helm test` needs both `tests` blocks
disabled there. (`tyk-control-plane` ships no test pod, so it has no `tests` block.)

`tyk-mdcb` renders no security context at all by default (both blocks ship empty), and
`tyk-operator.securityContext` is `{}` by default, so those need no opt-out unless you have added fields to them.

```yaml
tyk-gateway:
  gateway:
    securityContext:
      enabled: false
    containerSecurityContext:
      enabled: false
    initContainers:
      setupDirectories:
        securityContext:
          enabled: false
```

> **Note on the gateway init container.** The `setup-directories` init container falls back to
> `tyk-gateway.gateway.containerSecurityContext` when its own block is disabled or empty. Setting
> `initContainers.setupDirectories.securityContext.enabled: false` on its own therefore does not omit the block —
> it renders the main container's context instead. To omit it entirely, disable
> `gateway.containerSecurityContext` as well, as in the example above.
