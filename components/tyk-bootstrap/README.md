## Tyk Bootstrap

## Introduction
This chart helps with the bootstrapping of the Tyk Dashboard by creating a job which provisions the cluster with all the required secrets/configmaps/HTTP initialization calls on [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The chart provides little benefits by itself and should only be used in conjunction with other charts that also use the dashboard component.

## Prerequisites
* Kubernetes 1.19+
* Helm 3+

## Installing the Chart

To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-bootstrap`:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm show values tyk-helm/tyk-bootstrap > values-bootstrap.yaml
helm install tyk-bootstrap tyk-helm/tyk-bootstrap -n tyk --create-namespace -f values-bootstrap.yaml
```

## Uninstalling the Chart

```bash
helm uninstall tyk-bootstrap -n tyk
```

This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

``bash
helm upgrade tyk-bootstrap tyk-helm/tyk-bootstrap -n tyk
``

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). 

To get all configurable options with detailed comments:

```bash
helm show values tyk-helm/tyk-bootstrap > values-bootstrap.yaml
```
    
You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. Alternatively, you can use `--set` flag to set it in Tyk installation.

### Environment Variables

All environment variable configurations can be found in the README of official 
[`tyk-k8s-bootstrap`](https://github.com/TykTechnologies/tyk-k8s-bootstrap) repository.

