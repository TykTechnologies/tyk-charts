## Tyk Gateway
[Tyk](https://tyk.io) is an open source Enterprise API Gateway, supporting REST, GraphQL, TCP and gRPC protocols.

Tyk Gateway is provided ‘Batteries-included’, with no feature lockout. Enabling your organization to control who accesses your APIs,
when they access, and how they access it. Tyk Gateway can also be deployed as part of a larger Full Lifecycle API Management platform
Tyk Self-Managed which also includes Management Control Plane, Dashboard GUI and Developer Portal.

[Overview of Tyk Gateway](https://tyk.io/docs/apim/open-source/)

## Introduction
This chart defines a standalone open source Tyk Gateway component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For Tyk Open Source, please use [tyk-oss](../../tyk-oss)
* For Tyk Hybrid Gateway with Tyk Cloud or MDCB Remote Gateway, please use [tyk-data-plane](../../tyk-data-plane)
* For Tyk Self-Managed, please use [tyk-stack](../../tyk-stack)

[Learn more about different deployment options](https://tyk.io/docs/apim/)

## Prerequisites
* Kubernetes 1.19+
* Helm 3+
* [Redis](https://tyk.io/docs/planning-for-production/redis/) should already be installed or accessible by the gateway

## Installing the Chart

To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-gateway`:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm repo update
helm show values tyk-helm/tyk-gateway > values.yaml
```

Note: Set redis connection details first. See [Configuration](#configuration) below.

```bash
helm install tyk-gateway tyk-helm/tyk-gateway -n tyk --create-namespace -f values.yaml
```

## Uninstalling the Chart

```bash
helm uninstall tyk-gateway -n tyk
```

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

```bash
helm upgrade tyk-gateway tyk-helm/tyk-gateway -n tyk
```

*Note: pinned image tags and `runAsUser`*

The `runAsUser: 1000` defaults have been removed from `gateway.securityContext` (pod level) and
`gateway.containerSecurityContext` (container level) so that platforms such as OpenShift can assign a UID via a
Security Context Constraint. `runAsNonRoot: true` and `fsGroup` are retained, so kubelet now relies on the
image's `USER` directive.

The `setupDirectories` init container is the exception: it still pins
`gateway.initContainers.setupDirectories.securityContext.runAsUser: 65532`, because `busybox` has no `USER`
directive of its own and 65532 matches the gateway image's UID, so the directories it creates under
`/mnt/tyk-gateway` stay writable by the gateway. Override or disable that block separately on OpenShift.

If you pin `gateway.image.tag` to a version whose image has no numeric `USER` — for example `v5.9.1`, which runs
as `USER 0` — pods will fail admission on upgrade with `CreateContainerConfigError: container has runAsNonRoot
and image will run as root`. Images with a *symbolic* user (such as the distroless `nonroot` user) fail the same
way, because kubelet cannot verify a non-numeric user. Check yours with
`crane config <image> | jq -r '.config.User'` before upgrading. Either move to a tag with a numeric `USER` (the
chart default is `docker.tyk.io/tyk-gateway/tyk-gateway:v5.13.1`, `USER 65532`), set an explicit
`gateway.containerSecurityContext.runAsUser`, or set `gateway.containerSecurityContext.enabled: false` to omit
the block entirely and let the cluster decide.

### Upgrading from tyk-headless chart
Please see Migration notes in [tyk-oss](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-oss) chart

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). 

To get all configurable options with detailed comments:

```bash
helm show values tyk-helm/tyk-gateway > values.yaml
```

You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. 
Alternatively, you can use `--set` flag to set it in Tyk installation.

### Set Redis connection details (Required)
Tyk uses Redis for distributed rate-limiting and token storage. You may set `global.redis.addr` and `global.redis.pass` with redis connection string and password respectively.

If you do not already have redis installed, you can use these charts provided by Bitnami

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install tyk-redis bitnami/redis -n tyk --create-namespace
```

Follow the notes from the installation output to get connection details and password. The DNS name of your Redis as set 
by Bitnami is `tyk-redis-master.tyk.svc:6379` (Tyk needs the name including the port).
You can update them in your local values.yaml file under `global.redis.addrs` and `global.redis.pass`. 
Alternatively, you can use `--set` flag to set it in Tyk installation. For example `--set global.redis.pass=$REDIS_PASSWORD`

### Remote control plane credentials (hybrid / MDCB gateways)
When `global.remoteControlPlane.enabled` is true, the gateway's credentials can be supplied from externally managed
k8s Secrets rather than plaintext values. There are two independent settings:

* `global.remoteControlPlane.useSecretName` — reads `orgId`, `userApiKey` and `groupID` from the named Secret, using
  those exact key names.
* `global.remoteControlPlane.connectionStringSecretName` — reads the MDCB connection string from the named Secret into
  `TYK_GW_SLAVEOPTIONS_CONNECTIONSTRING`. The key defaults to `connectionString` and can be overridden with
  `global.remoteControlPlane.connectionStringSecretKey`.

`connectionStringSecretName` is independent of `useSecretName`: setting `useSecretName` does not make the chart look up
the connection string in a secret, so an install that keeps a literal `global.remoteControlPlane.connectionString` in
`values.yaml` alongside a credentials secret continues to work unchanged. The two may point at the same Secret or at
different ones.

### Enable autoscaling

This chart allows for easy configuration of autoscaling parameters. To simply enable autoscaling 
it's enough to add `--set gateway.autoscaling.enabled=true`. That will enable `Horizontal Pod Autoscaler` resource with 
default parameters (avg. CPU load at 60%, scaling between 1 and 3 instances). 
To customize those values you can add `--set gateway.autoscaling.averageCpuUtilization=75` or use `values.yaml` file:

```yaml
gateway:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 30
```

Built-in rules include `gateway.autoscaling.averageCpuUtilization` for CPU utilization (set by default at 60%) and 
`gateway.autoscaling.averageMemoryUtilization` for memory (disabled by default). 
In addition to that you can define rules for custom metrics using `gateway.autoscaling.autoscalingTemplate` list:

```yaml
gateway:
  autoscaling:
    autoscalingTemplate:
      - type: Pods
        pods:
          metric:
            name: nginx_ingress_controller_nginx_process_requests_total
          target:
            type: AverageValue
            averageValue: 10000m
```

### Graceful shutdown and rolling updates

For zero-downtime rollouts and scale-downs (for example when running behind an AWS ALB/NLB with
`target-type: ip` and pod readiness gates), you can tune how the Gateway pods terminate and how the
workload is updated:

- `gateway.terminationGracePeriodSeconds` — how long (in seconds) Kubernetes waits for a pod to shut
  down gracefully before sending `SIGKILL`. Unset by default, so the Kubernetes default of `30s`
  applies. When you configure graceful shutdown, set this greater than the sum of the Gateway's
  `graceful_shutdown_delay_seconds` and `graceful_shutdown_timeout_duration`.
- `gateway.lifecycle` — container lifecycle hooks (`preStop` / `postStart`). A `preStop` sleep keeps a
  terminating pod alive while the load balancer deregisters the target and drains in-flight connections.
- `gateway.strategy` — the update strategy. `type` defaults to `RollingUpdate`; you can override
  `rollingUpdate.maxSurge` and `rollingUpdate.maxUnavailable` (setting `maxUnavailable: 0` is useful for
  zero-downtime deployments with readiness gates). For `kind: StatefulSet`, `maxSurge` is not applicable
  and is omitted.

```yaml
gateway:
  terminationGracePeriodSeconds: 60
  lifecycle:
    preStop:
      sleep:
        seconds: 40    # sleep action requires Kubernetes >= 1.29 (GA in 1.30)
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 0
```

The Gateway's own shutdown timings (`graceful_shutdown_delay_seconds`,
`graceful_shutdown_timeout_duration`) can be set via `gateway.extraEnvs`.

> **Note on lifecycle hook handlers:** recent Tyk Gateway images are minimal and do not ship a shell or
> coreutils, so `exec` handlers such as `["/bin/sh", "-c", "sleep 40"]` or `["/bin/sleep", "40"]` will
> fail with an executable-not-found error. Use the native `sleep` handler shown above (Kubernetes 1.29+,
> GA in 1.30) instead — for connection draining it needs no shell and no network access.
>
> Two security points to keep in mind if you deviate from that:
>
> - An `exec` handler runs commands inside the container with the same permissions as the Gateway
>   process, so any command should be carefully reviewed before rollout.
> - An `httpGet` handler issues a request from inside the pod's network namespace, so it can reach
>   in-cluster services and cloud metadata endpoints that are not exposed externally. If you use one,
>   point it at a trusted endpoint on the Gateway itself, and make sure the URL neither returns
>   sensitive data nor triggers a side effect.

#### Enabling TLS
We have provided an easy way of enabling TLS via the `global.tls.gateway` flag. Setting this value to true will
automatically enable TLS using the certificate provided under tyk-gateway/certs/cert.pem.

If you want to use your own key/cert pair, you must follow the following steps:
1. Create a tls secret using your cert and key pair.
2. Set `global.tls.gateway`  to true.
3. Set `global.tls.useDefaultTykCertificate` to false.
4. Set `gateway.tls.secretName` to the name of the newly created secret.

#### OpenTelemetry
To enable OpenTelemetry for Gateway set `gateway.opentelemetry.enabled` flag to true. It is disabled by default.

You can also configure connection settings for it's exporter. By default `grpc` exporter is enabled on `localhost:4317` endpoint.

 To enable TLS settings for the exporter, you can set `gateway.opentelemetry.tls.enabled` to true. 
