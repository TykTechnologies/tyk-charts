# New Tyk Helm Charts
This is a repository for new Tyk helm charts. We will roll out new component charts and umbrella charts here as they are ready. Please visit the respective pages for each chart to learn how to install the chart and find out all the information relevant to that chart.

## Umbrella Charts
Helm umbrella chart (chart of charts) is an easy and really flexible way of installing multiple components as a single one. We have following umbrella charts that help you to install group of related tyk components based on your deployment need.

| Umbrella Charts | Description | Status |
|-----------------|-------------|--------|
| [tyk-oss](./tyk-oss)                | Tyk Open Source | Stable              |
| [tyk-stack](./tyk-stack)            | Tyk Self Managed (Single DC) | Beta            |
| tyk-control-plane | Tyk Self Managed (MDCB) Control Plane | Coming Soon     |
| [tyk-data-plane](./tyk-data-plane)    | Tyk Self Managed (MDCB) Data Plane <br> Tyk Hybrid Data Plane | Stable              |

## Component Charts
* [tyk-gateway](./components/tyk-gateway)
* [tyk-pump](./components/tyk-pump)
* [tyk-dashboard](./components/tyk-dashboard)
* [tyk-dev-portal](./components/tyk-dev-portal)
* tyk-mdcb (Coming soon!)
* tyk-tib (Coming soon!)
* tyk-operator (Coming soon!)

## External Dependencies - Redis and MongoDB/PostgreSQL
- Redis is required for all of the Tyk installations it must be installed in the cluster or reachable from inside K8s.
- MongoDB or PostgreSQL are only required for the Tyk Self-managed installation and must be installed in the cluster, or reachable from inside K8s. If you are using the MongoDB or SQL pumps in the `tyk-oss` installation you will require MongoDB or PostgreSQL installed for that as well.
- (Coming soon!) There is an easy option for you to spawn a Redis/MongDB/PostgreSQL instance using Bitnami's chart as a sub-chart. This is handy if you want to quickly spin up the whole stack without installing Redis and the Database separately. This is NOT recommended for production use.

## Kubernetes Ingress
For further detail on how to configure Tyk as an Ingress Gateway, or how to manage APIs in Tyk using the Kubernetes API, please refer to our [Tyk Operator documentation](https://tyk.io/docs/tyk-operator/). The Tyk Operator can be installed along this chart and works with all installation types.
