# Tyk Helm Charts
This is a repository for Tyk helm charts. Please visit the official website to learn about Tyk's [Licensing and deployment models](https://tyk.io/docs/tyk-on-premises/licensing/) and the different [Helm Charts](https://tyk.io/docs/product-stack/tyk-charts/overview/) availble for Kubernetes deployment.

## Usage
[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
```

## Helm Charts
You can then run `helm search repo tyk-helm` to see the charts.

### Umbrella Charts
Helm umbrella chart (chart of charts) is an easy and really flexible way of installing multiple components as a single one. We have following umbrella charts that help you to install group of related tyk components based on your deployment need.

| Umbrella Charts                          | Description                                                   | Status |
|------------------------------------------|---------------------------------------------------------------|--------|
| [tyk-oss](./tyk-oss)                     | Tyk Open Source                                               | Stable |
| [tyk-stack](./tyk-stack)                 | Tyk Self Managed                                              | Stable |
| [tyk-control-plane](./tyk-control-plane) | Tyk Self Managed (MDCB) Control Plane                         | Stable |
| [tyk-data-plane](./tyk-data-plane)       | Tyk Self Managed (MDCB) Data Plane <br> Tyk Hybrid Data Plane | Stable |

### Component Charts
* [tyk-gateway](./components/tyk-gateway)
* [tyk-pump](./components/tyk-pump)
* [tyk-dashboard](./components/tyk-dashboard)
* [tyk-dev-portal](./components/tyk-dev-portal)
* [tyk-mdcb](./components/tyk-mdcb)

### Other Charts
Tyk Operator's helm chart is managed in [tyk-operator](https://github.com/TykTechnologies/tyk-operator) repository.

## External Dependencies - Redis and MongoDB/PostgreSQL
- Redis is required for all of the Tyk installations it must be installed in the cluster or reachable from inside K8s.
- MongoDB or PostgreSQL are only required for the Tyk Self-managed installation and must be installed in the cluster, or reachable from inside K8s. If you are using the MongoDB or SQL pumps in the `tyk-oss` installation you will require MongoDB or PostgreSQL installed for that as well.
- (Coming soon!) There is an easy option for you to spawn a Redis/MongDB/PostgreSQL instance using Bitnami's chart as a sub-chart. This is handy if you want to quickly spin up the whole stack without installing Redis and the Database separately. This is NOT recommended for production use.

## Kubernetes Ingress
For further detail on how to configure Tyk as an Ingress Gateway, or how to manage APIs in Tyk using the Kubernetes API, please refer to our [Tyk Operator documentation](https://tyk.io/docs/tyk-operator/). The Tyk Operator can be installed along this chart and works with all installation types.
