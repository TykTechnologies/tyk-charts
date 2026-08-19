## Tyk Operator

Tyk Operator brings Full Lifecycle API Management capabilities to Kubernetes. Configure Ingress, APIs, Security Policies, Authentication, Authorization, Mediation and more - all using GitOps best practices with Custom Resources and Kubernetes-native primitives.

### Usage

```bash
helm repo add tyk-charts https://helm.tyk.io/public/helm/charts/
helm repo update
```

### Prerequisites

Before installing Tyk Operator ensure you follow this guide and complete all 
steps from it, otherwise Tyk Operator won't function properly: [https://github.com/TykTechnologies/tyk-operator/blob/master/docs/installation/installation.md#tyk-operator-installation](https://tyk.io/docs/tyk-stack/tyk-operator/installing-tyk-operator/)

**_NOTE_:** cert-manager is required as described [here](https://tyk.io/docs/tyk-stack/tyk-operator/installing-tyk-operator/#step-2-installing-cert-manager). If you haven't installed `cert-manager` yet, you can install it as follows:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
```

### Installation
If you have a fully functioning & bootstrapped Tyk Installation and cert-manager, 
you can install Tyk Operator as follows: 

```bash
helm install tyk-operator tyk-charts/tyk-operator
```

By default, it will install the latest stable release of Tyk Operator.

You can install any other version by 
1. Setting `image.tag` in values.yml or with `--set {image.tag}={VERSION_TAG}` while doing the helm install. 
2. Installing CRDs of the corresponding version. This is important as operator might not work otherwise. You can do so by running the below command. 

```bash
kubectl apply -f https://raw.githubusercontent.com/TykTechnologies/tyk-charts/refs/heads/main/tyk-operator-crds/crd-$TYK_OPERATOR_VERSION.yaml
```

Replace $TYK_OPERATOR_VERSION with the image tag corresponding to the Tyk Operator version to which the Custom Resource Definitions (CRDs) belong.
For example, to install CRDs compatible with Tyk Operator v1.0.0, set $TYK_OPERATOR_VERSION to v1.0.0.

For detailed documentation, please refer to the official Tyk documentation https://tyk.io/docs/tyk-operator/.
