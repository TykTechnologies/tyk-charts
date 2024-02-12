## Tyk Multi Data Centre Bridge (MDCB)

Tyk’s Multi Data Centre Bridge (MDCB) is a separately licensed extension to the Tyk control plane that performs management 
and synchronisation of logically or geographically distributed clusters of Tyk API Gateways. 

## Introduction
This chart defines a standalone Tyk MDCB component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For single data centre deployment, please use [tyk-stack](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-stack)
* For multi data centre deployment, please use tyk-control-plane (Coming soon!)

[Learn more about different deployment options](https://tyk.io/docs/apim/)

## Prerequisites
* Kubernetes 1.19+
* Helm 3+
* [Tyk Gateway](../tyk-gateway)
* [Tyk Dashboard](../tyk-dashboard)
* [Redis](https://tyk.io/docs/planning-for-production/redis/) should already be installed or accessible by the gateway
*  [MongoDB](https://tyk.io/docs/planning-for-production/database-settings/mongodb/) or [PostgreSQL](https://tyk.io/docs/planning-for-production/database-settings/postgresql/)


## Installing the Chart

To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-mdcb`:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm show values tyk-helm/tyk-mdcb > values.yaml --devel
```

Note:
* Set Redis connection details at `.Values.global.redis`
* Set MongoDB or Postgres connection details at `.Values.global.mongo` or `.Values.global.postgres` respectively.
* The Tyk MDCB also requires a license to be set at `.Values.mdcb.license`

```bash
helm install tyk-mdcb tyk-helm/tyk-mdcb -n tyk --create-namespace -f values.yaml --devel
```

## Uninstalling the Chart

```bash
helm uninstall tyk-mdcb -n tyk
```

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

```bash
helm upgrade tyk-mdcb tyk-helm/tyk-mdcb -n tyk --devel
```

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

To get all configurable options with detailed comments:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm show values tyk-helm/tyk-mdcb > values.yaml --devel
```

You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation.
Alternatively, you can use `--set` flag to set it in Tyk installation.

### Set Redis connection details (Required)
Tyk uses Redis for distributed rate-limiting and token storage.
You may set `global.redis.addr` and `global.redis.pass` with Redis connection string and password respectively.

If you do not already have Redis installed, you can use these charts provided by Bitnami

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install tyk-redis bitnami/redis -n tyk --create-namespace
```

Follow the notes from the installation output to get connection details and password.
The DNS name of your Redis as set by Bitnami is `tyk-redis-master.tyk.svc:6379` (Tyk needs the name including the port).

You can update them in your local values.yaml file under `global.redis.addrs` and `global.redis.pass`.
Alternatively, you can use `--set` flag to set it in Tyk installation. For example `--set global.redis.pass=$REDIS_PASSWORD`

### Set MongoDB or PostgreSQL connection details (Required)
If you have already installed MongoDB or PostgreSQL, you can set the connection details in `global.mongo` and `global.postgres` section of values file respectively.

If not, you can use these rather excellent charts provided by Bitnami to install MongoDB or PostgreSQL:

**MongoDB Installation**

```bash
helm install tyk-mongo bitnami/mongodb --version {HELM_CHART_VERSION} --set "replicaSet.enabled=true" -n tyk
```

**PostgreSQL Installation**
```bash
helm install tyk-postgres bitnami/postgresql --set "auth.database=tyk_analytics" -n tyk
```

Follow the notes from the installation output to get connection details.

>NOTE: Please make sure you are installing MongoDB or PostgreSQL versions that are supported by Tyk. Please refer to Tyk docs to get list of supported versions.

### Tyk MDCB Configuration

#### Tyk MDCB License

Tyk MDCB requires a license to be set at `.Values.mdcb.license`. This field is mandatory and must be configured.

To enhance security and avoid storing plaintext values for the MDCB license directly in the Helm value file,
an alternative approach is available. You can store the license in a Kubernetes Secret and reference it externally. 
Set the license in the Kubernetes Secret and provide the secret's name through `.Values.mdcb.useSecretName`. 
The Secret must contain a key named `MDCBLicense`.

#### Tyk MDCB Listen Port

The `.Values.mdcb.listenPort` field represents a RPC port which worker Tyk Gateways will connect to.
Setting `.Values.mdcb.listenPort` field opens a port on MDCB container and MDCB service targets this port.
It is used to set `TYK_MDCB_LISTENPORT`

#### Tyk MDCB Health Check Port
The health check port for Tyk MDCB can be configurable via `.Values.mdcb.probes.healthCheckPort` field.  This port lets MDCB allow standard health checks.

It also defines the path for liveness and readiness probes.
It is used to set TYK_MDCB_HEALTHCHECKPORT