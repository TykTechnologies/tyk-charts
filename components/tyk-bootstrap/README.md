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
helm show values tyk-helm/tyk-bootstrap > values-bootstrap.yaml --devel
helm install tyk-bootstrap tyk-helm/tyk-bootstrap -n tyk --create-namespace -f values-bootstrap.yaml --devel
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
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To get all configurable options with detailed comments:

```bash
helm show values tyk-helm/tyk-bootstrap > values-bootstrap.yaml --devel
```
    
You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. Alternatively, you can use `--set` flag to set it in Tyk installation.

### Environment Variables

| Environment Variable                           | Description                                                                                                                                                                                                           |
|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| TYK_K8SBOOTSTRAP_INSECURESKIPVERIFY            | enables InsecureSkipVerify options in HTTP requests sent to Tyk -<br/> might be useful for Tyk Dashboard with self-signed certs                                                                                       |
| TYK_K8SBOOTSTRAP_BOOTSTRAPDASHBOARD            | controls bootstrapping Tyk Dashboard or not.                                                                                                                                                                          |
| TYK_K8SBOOTSTRAP_BOOTSTRAPPORTAL               | controls bootstrapping Tyk Classic Portal or not.                                                                                                                                                                     |
| TYK_K8SBOOTSTRAP_OPERATORKUBERNETESSECRETNAME  | corresponds to the Kubernetes secret name that will be created for Tyk Operator.<br/> Set it to an empty to string to disable bootstrapping Kubernetes secret for Tyk Operator.                                       |
| TYK_K8SBOOTSTRAP_DEVPORTALKUBERNETESSECRETNAME | corresponds to the Kubernetes secret name that will be created for Tyk Developer Enterprise Portal.<br/> Set it to an empty to string to disable bootstrapping Kubernetes secret for Tyk Developer Enterprise Portal. |
| TYK_K8SBOOTSTRAP_K8S_DASHBOARDSVCURL           | corresponds to the URL of Tyk Dashboard.                                                                                                                                                                              |
| TYK_K8SBOOTSTRAP_K8S_DASHBOARDSVCPROTO         | corresponds to Tyk Dashboard Service Protocol (either http or https). By default, it is http.                                                                                                                         |
| TYK_K8SBOOTSTRAP_K8S_RELEASENAMESPACE          | corresponds to the namespace where Tyk is deployed via Helm Chart.                                                                                                                                                    |
| TYK_K8SBOOTSTRAP_K8S_DASHBOARDDEPLOYMENTNAME   | corresponds to the name of the Tyk Dashboard Deployment, which is being used to restart<br/> Dashboard pod after bootstrapping.                                                                                       |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_SECRET              | corresponds to the secret that will be used in Admin APIs.                                                                                                                                                            |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_FIRSTNAME           | corresponds to the first name of the admin being created.                                                                                                                                                             |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_LASTNAME            | corresponds to the last name of the admin being created.                                                                                                                                                              |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_EMAILADDRESS        | corresponds to the email address of the admin being created.                                                                                                                                                          |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_PASSWORD            | corresponds to the password of the admin being created.                                                                                                                                                               |
| TYK_K8SBOOTSTRAP_TYK_ADMIN_AUTH                | corresponds to Tyk Dashboard API Access Credentials of the admin user, and it will be used in Authorization <br/>header of the HTTP requests that will be sent to Tyk for bootstrapping.                              |
| TYK_K8SBOOTSTRAP_TYK_ORG_NAME                  | corresponds to the name for your organization that is going to be bootstrapped in Tyk.                                                                                                                                |
| TYK_K8SBOOTSTRAP_TYK_ORG_CNAME                 | corresponds to the Organisation CNAME which is going to bind the Portal to.                                                                                                                                           |
| TYK_K8SBOOTSTRAP_TYK_ORG_ID                    | corresponds to the organisation ID that is being created.                                                                                                                                                             |
| TYK_K8SBOOTSTRAP_TYK_DASHBOARDLICENSE          | corresponds to the license key of Tyk Dashboard.                                                                                                                                                                      |
