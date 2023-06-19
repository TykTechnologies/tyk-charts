## Tyk Dashboard
[Tyk](https://tyk.io) is an open source Enterprise API Dashboard, supporting REST, GraphQL, TCP and gRPC protocols.

Tyk Dashboard is provided ‘Batteries-included’, with no feature lockout. Enabling your organization to control who accesses your APIs, when they access, and how they access it. Tyk Dashboard can also be deployed as part of a larger Full Lifecycle API Management platform Tyk Self-Managed which also includes Management Control Plane, Dashboard GUI and Developer Portal.

[Overview of Tyk Dashboard](https://tyk.io/docs/tyk-dashboard/)

## Introduction
This chart defines a standalone Tyk Dashboard component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For single data centre deployment, please use [tyk-single-dc](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-single-dc)
* For multi data centre deployment, please use tyk-mdcb-control-plane (Coming soon!)

[Learn more about different deployment options](https://tyk.io/docs/apim/)

## Prerequisites
* Kuberentes 1.19+
* Helm 3+
* [Redis](https://tyk.io/docs/planning-for-production/redis/) should already be installed or accessible by the dashboard 
* [Mongo](https://tyk.io/docs/planning-for-production/database-settings/mongodb/) or [PostgreSQL](https://tyk.io/docs/planning-for-production/database-settings/postgresql/) should already be installed or accessible by the dashboard

## Installing the Chart

To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-dashboard`:

    helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
    helm show values tyk-helm/tyk-dashboard > values-dashboard.yaml
    helm install tyk-dashboard tyk-helm/tyk-dashboard -n tyk --create-namespace -f values-dashboard.yaml

Note: Set redis connection details first. See [Configuration](#configuration) below.

    helm install tyk-dashboard tyk-dashboard -n tyk --create-namespace -f values.yaml

## Uninstalling the Chart

    helm uninstall tyk-dashboard -n tyk

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

    helm upgrade tyk-dashboard tyk-helm/tyk-dashboard -n tyk

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To get all configurable options with detailed comments:

    helm show values tyk-helm/tyk-dashboard > values.yaml
    
You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. Alternatively, you can use `--set` flag to set it in Tyk installation.

### Set Redis connection details (Required)
Tyk uses Redis for distributed rate-limiting and token storage. You may set `global.redis.addr` and `global.redis.pass` with redis connection string and password respectively.

If you do not already have redis installed, you can use these charts provided by Bitnami

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install tyk-redis bitnami/redis -n tyk --create-namespace

Follow the notes from the installation output to get connection details and password. The DNS name of your Redis as set by Bitnami is `tyk-redis-master.tyk.svc.cluster.local:6379` (Tyk needs the name including the port) You can update them in your local values.yaml file under `global.redis.addrs` and `global.redis.pass`. Alternatively, you can use `--set` flag to set it in Tyk installation. For example `--set global.redis.pass=$REDIS_PASSWORD`

### Set Mongo or PostgresSQL connection details (Required)
If you have already installed mongo/postgresSQL, you can set the connection details in `global.mongo` and `global.postgres` section of values file respectively.

If not, you can use these rather excellent charts provided by Bitnami to install mongo/postgres:

**Mongo Installation**

```
helm install tyk-mongo bitnami/mongodb --version {HELM_CHART_VERSION} --set "replicaSet.enabled=true" -n tyk
```

**PostgresSQL Installation**
```
helm install tyk-postgres bitnami/postgresql --set "auth.database=tyk_analytics" -n tyk
```

Follow the notes from the installation output to get connection details.

>NOTE: Please make sure you are installing mongo/postgres versions that are supported by Tyk. Please refer to Tyk docs to get list of supported versions.

### Dashboard Configurations

#### Enabling TLS
We have provided an easy way of enabling TLS via the `global.tls.dashboard` flag. Setting this value to true will
automatically enable TLS using the certificate provided under tyk-dashboard/certs/cert.pem.

If you want to use your own key/cert pair, you must follow the following steps:
1. Create a tls secret using your cert and key pair.
2. Set `global.tls.dashboard` to true.

