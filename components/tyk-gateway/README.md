## Tyk Gateway
[Tyk](https://tyk.io) is an open source Enterprise API Gateway, supporting REST, GraphQL, TCP and gRPC protocols.

Tyk Gateway is provided ‘Batteries-included’, with no feature lockout. Enabling your organization to control who accesses your APIs, when they access, and how they access it. Tyk Gateway can also be deployed as part of a larger Full Lifecycle API Management platform Tyk Self-Managed which also includes Management Control Plane, Dashboard GUI and Developer Portal.

[Overview of Tyk Gateway](https://tyk.io/docs/apim/open-source/)

## Introduction
This chart defines a standalone open source Tyk Gateway component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For Tyk Open Source, please use [tyk-oss](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-oss)
* Coming soon: For Tyk Hybrid Gateway, please use [tyk-hybrid-gateway](https://github.com/TykTechnologies/tyk-charts/tree/main/)
* Coming soon: For Tyk Self-Managed, please use [tyk-self-managed](https://github.com/TykTechnologies/tyk-charts/tree/main/)

[Learn more about different deployment options](https://tyk.io/docs/apim/)

## Prerequisites
* Kuberentes 1.19+
* Helm 3+
* [Redis](https://tyk.io/docs/planning-for-production/redis/) should already be installed or accessible by the gateway 

## Installing the Chart
<!--
To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-gateway`:

    helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
    helm repo update
    helm show values tyk-helm/tyk-gateway > values-gateway.yaml
    helm install tyk-gateway tyk-helm/tyk-gateway -n tyk --create-namespace -f values-gateway.yaml
-->

Note: Set redis connection details first. See [Configuration](#configuration) below.

    helm install tyk-gateway tyk-gateway -n tyk --create-namespace -f values.yaml

## Uninstalling the Chart

    helm uninstall tyk-gateway -n tyk

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

    helm upgrade tyk-gateway tyk-gateway -n tyk

### Upgrading from tyk-headless chart
Please see Migration notes in [tyk-oss](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-oss) chart

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To get all configurable options with detailed comments:

    helm show values tyk-gateway > values.yaml
    
You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. Alternatively, you can use `--set` flag to set it in Tyk installation.

### Set Redis conenction details (Required)
Tyk uses Redis for distributed rate-limiting and token storage. You may set `global.redis.addr` and `global.redis.pass` with redis connection string and password respectively.

If you do not already have redis installed, you can use these charts provided by Bitnami

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install tyk-redis bitnami/redis -n tyk --create-namespace

Follow the notes from the installation output to get connection details and password. The DNS name of your Redis as set by Bitnami is `tyk-redis-master.tyk.svc.cluster.local:6379` (Tyk needs the name including the port) You can update them in your local values.yaml file under `global.redis.addrs` and `global.redis.pass`. Alternatively, you can use `--set` flag to set it in Tyk installation. For example `--set global.redis.pass=$REDIS_PASSWORD`

### Gateway Configurations

#### Enabling TLS
We have provided an easy way of enabling TLS via the `gateway.tls.enabled` flag. Setting this value to true will
automatically enable TLS using the certificate provided under tyk-gateway/certs/cert.pem.

If you want to use your own key/cert pair, you must follow the following steps:
1. Create a tls secret using your cert and key pair.
2. Set `gateway.tls.enabled`  to true.
3. Set `gateway.tls.useDefaultTykCertificate` to false.
4. Set `gateway.tls.secretName` to the name of the newly created secret.
