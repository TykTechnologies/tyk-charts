## Tyk Dashboard
The [Tyk Dashboard](https://tyk.io/docs/tyk-dashboard/) is the GUI and analytics platform for Tyk. It provides an easy-to-use management interface for managing a Tyk installation as well as clear and granular analytics.

The Dashboard also provides the [API Classic Developer Portal](https://tyk.io/docs/tyk-developer-portal/), a customisable developer portal for your API documentation, developer auto-enrolment and usage tracking.

## Introduction
This chart defines a standalone Tyk Dashboard component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For single data centre deployment, please use [tyk-stack](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-stack)
* For multi data centre deployment, please use tyk-control-plane (Coming soon!)

[Learn more about Tyk Licensing and Deployment models](https://tyk.io/docs/tyk-on-premises/licensing/)

## Prerequisites
* Kubernetes 1.19+
* Helm 3+
* [Redis](https://tyk.io/docs/planning-for-production/redis/) should already be installed or accessible by the dashboard 
* [MongoDB](https://tyk.io/docs/planning-for-production/database-settings/mongodb/) or [PostgreSQL](https://tyk.io/docs/planning-for-production/database-settings/postgresql/) should already be installed or accessible by the dashboard

## Installing the Chart

To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-dashboard`:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm show values tyk-helm/tyk-dashboard > values-dashboard.yaml
```

Note: 
* Set Redis connection details at `.Values.global.redis`
* Set MongoDB connection details at `.Values.global.mongo`
* The Tyk Dashboard also requires a license to be set at `.Values.global.license.dashboard`
* The Tyk Dashboard will require bootstrapping in order to work. This can be achieved by running the component
chart "tyk-bootstrap"

```bash
helm install tyk-dashboard tyk-helm/tyk-dashboard -n tyk --create-namespace -f values-dashboard.yaml
```

## Uninstalling the Chart

```bash
helm uninstall tyk-dashboard -n tyk
```

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

```bash
helm upgrade tyk-dashboard tyk-helm/tyk-dashboard -n tyk
```

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). 
To get all configurable options with detailed comments:

```bash
helm show values tyk-helm/tyk-dashboard > values.yaml
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

### Dashboard Configurations

#### Enabling TLS

Assuming that TLS certificates for the Tyk Dashboard are available in the Kubernetes Secret `tyk-dashboard-tls`, 
follow these steps to enable TLS:

1. Set `global.tls.dashboard` to `true`.
2. Set `dashboard.tls.secretName` to the name of the Kubernetes secret containing TLS certificates for the Tyk Dashboard, in this case, `tyk-dashboard-tls`.
3. Define certificate configurations in `dashboard.tls.certificates`, which generates `TYK_DB_HTTPSERVEROPTIONS_CERTIFICATES` for the Tyk Dashboard.

> Optional Steps, if needed:
>  
> - Modify the secret mount path on the Tyk Dashboard Pod via `dashboard.tls.certificatesMountPath`.
> - If necessary, either enable `insecureSkipVerify` via `dashboard.tls.certificates`, or mount CA information through `dashboard.extraVolumes` and `dashboard.extraVolumeMounts`.
> - If the `tyk-bootstrap` chart is used to bootstrap the Tyk Dashboard, ensure that it has certificates to send requests to the Tyk Dashboard or enable `insecureSkipVerify` in the `tyk-bootstrap` chart.
> - If the Tyk Gateway connects to the Tyk Dashboard, confirm that the Tyk Gateway has appropriate certificates for connecting to the Tyk Dashboard
