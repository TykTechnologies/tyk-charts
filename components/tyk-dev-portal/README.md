## Tyk Developer Portal
The Tyk Developer Portal is the most flexible and straightforward way for API providers to publish, monetise and drive the adoption of APIs. It provides a full-fledged CMS-like system that enables you to serve all stages of API adoption: from the look and feel customisation to exposing APIs and enabling third-party developers to register and use your APIs.

## Introduction
This chart defines a standalone Tyk Developer Portal component on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

For typical usage, we recommend using following umbrella charts:
* For single data centre deployment, please use [tyk-stack](https://github.com/TykTechnologies/tyk-charts/tree/main/tyk-stack)

[Learn more about different deployment options](https://tyk.io/docs/apim/)

## Prerequisites
* Kubernetes 1.19+
* Helm 3+
* Tyk Dashboard instance

## Installation
### 1. Create Kubernetes Secret

Make sure the Kubernetes secret exists in your namespace containing Tyk Dashboard Organisation ID and Tyk Dashboard API Access Credentials.

This secret will automatically be generated if [tyk-bootstrap](../tyk-bootstrap/) component chart was installed with `bootstrap.devPortal` value set to true in the values.yaml.

If the secret does not exist, you can create it by running the following command.

```bash
kubectl create secret generic tyk-dev-portal-conf -n ${NAMESPACE} \
  --from-literal=TYK_ORG=${TYK_ORG} \
  --from-literal=TYK_AUTH=${TYK_AUTH}
```

The fields `TYK_ORG` and `TYK_AUTH` are the Tyk Dashboard _Organisation ID_ and the Tyk Dashboard API _Access Credentials_ respectively. These can be obtained under your profile in the Tyk Dashboard.

### 2. Install chart
To install the chart from the Helm repository in namespace `tyk` with the release name `tyk-dev-portal`:
```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
helm show values tyk-helm/tyk-dev-portal > values.yaml 
```
> [!NOTE]
> Set license key at `.Values.license`

 By default, Helm chart will try to discover Tyk Dashboard service in the same namespace. If you want to explicitly specify Tyk Dashboard URL, you can set `.Values.overrideTykDashUrl` in values.yaml file.

```bash
helm install tyk-dev-portal tyk-helm/tyk-dev-portal -n tyk --create-namespace -f values.yaml
```
## Uninstalling the Chart
```bash
helm uninstall tyk-dev-portal -n tyk
```

This removes all the Kubernetes resources associated with the chart and deletes the release.

## Upgrading Chart
```bash
helm upgrade tyk-dev-portal tyk-helm/tyk-dev-portal -n tyk
```

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To get all configurable options with detailed comments:
```bash
helm show values tyk-helm/tyk-tyk-dev-portal > values.yaml 
```
    
You can update any value in your local values.yaml file and use `-f [filename]` flag to override default values during installation. Alternatively, you can use `--set` flag to set it during chart installation.

### Tyk Developer Enterprise Portal License (Required)

Tyk Developer Enterprise Portal License is required. It can be set up in `license` or through secret `useSecretName`. The secret should contain a key called `DevPortalLicense`.

```yaml
# Developer Portal license.
license: ""
```

### Storage Settings

Tyk Enterprise Portal supports different storage options for storing the portal's CMS assets such as images, theme files and Open API Specification files. Please see the [Enterprise Portal Storage settings](https://tyk.io/docs/tyk-stack/tyk-developer-portal/enterprise-developer-portal/install-tyk-enterprise-portal/configuration#portal-settings) page for all the available options. Helm chart supports the setting of the following fields in `storage` section:

```yaml
storage:
  # Configuration values for using an SQL database as storage for Tyk Developer Portal
  # In case you want to provide the connection string via secrets please
  # refer to the existing secret inside the helmchart or the
  # .Values.global.secrets.useSecretName variable
  # User can set the storage type for portal.
  # Supported types: fs, s3, db
  type: "db"
  # Configuration values for using s3 as storage for Tyk Developer Portal
  # In case you want to provide the key ID and access key via secrets please
  # refer to the existing secret inside the helm chart or the
  # .Values.useSecretName field and a secret containing
  # the keys DevPortalAwsAccessKeyId and respectively,
  # DevPortalAwsSecretAccessKey
  s3:
    awsAccessKeyid: your-access-key
    awsSecretAccessKey: your-secret-key
    region: sa-east-1
    endpoint: your-portal-bucket
    bucket: https://s3.sa-east-1.amazonaws.com
    acl: private
    presign_urls: true
  persistence:
    # User can mount existing PVC to enterprise portal
    # Make sure to change the kind to Deployment if you are mounting existing PVC 
    mountExistingPVC: ""
    storageClass: ""
    accessModes:
      - ReadWriteOnce
    size: 8Gi
    annotations: {}
    labels: {}
    selector: {}
```

### Database Settings
Portal uses database to store metadata related to the portal, such as API products, plans, developers, applications, and more.
Please refer to [Database connection settings](https://tyk.io/docs/product-stack/tyk-enterprise-developer-portal/deploy/configuration/#database-connection-settings) for more details.

Helm chart provides following configuration options for database connection:

```yaml
database:
  # This selects the SQL dialect to be used
  # The supported values are mysql, postgres and sqlite3
  dialect: "sqlite3"
  connectionString: "db/portal.db"
  enableLogs: false
  maxRetries: 3
  retryDelay: 5000
```



### Other Configurations

Other [Enterprise Portal configurations](https://tyk.io/docs/tyk-stack/tyk-developer-portal/enterprise-developer-portal/install-tyk-enterprise-portal/configuration) can be set by using environment variables with `extraEnvs` fields, e.g.:

```yaml
extraEnvs:
  - name: PORTAL_LOG_LEVEL
    value: debug
```


## Protect Confidential Fields with Kubernetes Secrets
In the `values.yaml` file, some fields are considered confidential, such as Developer Portal license, connection strings, etc.
Declaring values for such fields as plain text might not be desired for all use cases. Instead, for certain fields,
Kubernetes secrets can be referenced, and Kubernetes by itself configures values based on the referred secret.

This section describes how to use Kubernetes secrets to declare confidential fields.

### Tyk Developer Enterprise Portal License

In order to refer Tyk Developer Enterprise Portal license through Kubernetes secret, please use `useSecretName`, 
where the secret should contain a key called `DevPortalLicense`.

### Tyk Developer Enterprise Portal Admin Password

In order to refer Tyk Developer Enterprise Portal's admin password through Kubernetes secret, 
please use `global.adminUser.useSecretName`, where the secret should contain a key called `adminUserPassword`.

### Tyk Developer Enterprise Portal Database Connection String

In order to refer Tyk Enterprise Portal connection string to the selected database through Kubernetes secret,
please use `useSecretName`, where the secret should contain a key called 
`DevPortalDatabaseConnectionString `.

> [!WARNING]
> If `useSecretName` is in use, please add all keys mentioned above to the secret. 
    
