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
| [tyk-oss](https://tyk.io/docs/product-stack/tyk-charts/tyk-oss-chart/)                     | Tyk Open Source                                               | Stable |
| [tyk-stack](https://tyk.io/docs/product-stack/tyk-charts/tyk-stack-chart/)                 | Tyk Self Managed                                              | Stable |
| [tyk-control-plane](https://tyk.io/docs/product-stack/tyk-charts/tyk-control-plane-chart/) | Tyk Self Managed (MDCB) Control Plane                         | Stable |
| [tyk-data-plane](https://tyk.io/docs/product-stack/tyk-charts/tyk-data-plane-chart/)       | Tyk Self Managed (MDCB) Data Plane <br> Tyk Hybrid Data Plane | Stable |

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

## Running the tests

The GitHub workflows are the source of truth for what gets tested:
[`unit-tests.yaml`](.github/workflows/unit-tests.yaml) and
[`run-tests.yaml`](.github/workflows/run-tests.yaml). The commands here reproduce those jobs
on your own machine. Where a local run cannot match CI, this section says so.

Run every snippet with `bash`. The loops and the unquoted `--set` braces below are bash
syntax, and they behave differently under other shells.

### Prerequisites

You need the following software. Install each from its own project, so the instructions match
your platform.

| Software | Version | Why you need it |
|----------|---------|-----------------|
| [Docker](https://docs.docker.com/engine/install/) | Any current release | kind runs the cluster inside a container. Docker Desktop and a standalone Docker Engine both work. |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Matching your cluster | Creating namespaces, reading secrets, and inspecting pods. |
| [Helm](https://helm.sh/docs/intro/install/) | 3.x | Rendering and installing the charts. CI uses Helm 3. Helm 4 works, with one caveat below. |
| [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) | Any current release | Creating the throwaway cluster that the smoke and integration tests run against. |
| [Git](https://git-scm.com/downloads) | 2.17.0 or later | chart-testing reads git history to detect changed charts. |

You also need three test tools:
[chart-testing](https://github.com/helm/chart-testing) for linting, plus
[yamllint](https://github.com/adrienverge/yamllint) and
[yamale](https://github.com/23andMe/Yamale), which chart-testing calls but does not install.

Pick whichever route suits your platform:

```bash
# A package manager, if one carries all three
brew install chart-testing yamllint

# Or a chart-testing release binary plus pip for the two Python tools
# https://github.com/helm/chart-testing/releases
pip install yamllint yamale
```

Most Linux distributions also package yamllint. chart-testing only needs `yamllint` and
`yamale` on your `PATH`, so any install method works.

If you would rather not install the three on your host, the
[chart-testing container image](https://quay.io/repository/helmpack/chart-testing) bundles
them.

Finally, install the unit-test plugin. This command is the same on every platform:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git --version v0.7.2 --verify=false
```

Two notes on that command:

- `--verify=false` is required on Helm 4, which verifies plugin provenance and refuses a git
  source without it. Helm 3 accepts the command without the flag, which is why CI omits it.
- The plugin carries its own Helm 3 SDK, so unit tests render through Helm 3 whichever Helm
  you install. A passing unit-test run tells you nothing about Helm 4 rendering.

### Unit tests

Unit tests need no cluster and finish in seconds. Run them first when you change a template.

```bash
for chart in tyk-control-plane tyk-data-plane tyk-oss tyk-stack; do
  helm dependency update "./$chart"
done

helm unittest \
  ./components/tyk-bootstrap \
  ./components/tyk-dashboard \
  ./components/tyk-dev-portal \
  ./components/tyk-pump \
  ./tyk-control-plane \
  ./tyk-stack
```

The umbrella charts pull their components in over `file://` dependencies, so their suites
cannot render until `helm dependency update` vendors those into `charts/`.

CI discovers the chart list rather than hardcoding it, so a new suite is picked up without a
workflow edit. A chart qualifies only if it holds `tests/*_test.yaml` at its root. Charts
whose only `tests/` directory sits under `templates/` hold `helm test` hook pods instead, and
CI skips them.

### Linting

```bash
helm repo add tyk-helm https://helm.tyk.io/public/helm/charts/
ct lint --config ct.yaml --all
```

`ct lint` covers the four umbrella charts only, because `chart-dirs` in [`ct.yaml`](ct.yaml)
searches one level down. This command does not lint the charts under `components/`.

Linting also vendors the `charts/` directories, so a later `helm dependency update` has
nothing left to do.

### Smoke and integration tests

These need a cluster:

```bash
kind create cluster --name tyk-charts --config scripts/kind-cluster.yaml --wait 180s
```

Delete it when you finish:

```bash
kind delete cluster --name tyk-charts
```

For the install and `helm test` commands, follow the steps in
[`run-tests.yaml`](.github/workflows/run-tests.yaml) rather than a second copy kept here. The
workflow is what CI runs, and a duplicate drifts out of date.

Two of the three integration paths need credentials that this repository does not carry:

| Path | Requires |
|------|----------|
| `tyk-oss` | Nothing beyond Redis |
| `tyk-stack` | A dashboard license, plus MongoDB |
| `tyk-data-plane` | `HYBRID_RPC_KEY`, `HYBRID_API_KEY`, and `HYBRID_MDCB_HOST` |

Export a license rather than writing it into a values file, so it stays out of any file you
might commit:

```bash
export DASH_LICENSE='...'
helm install --namespace tyk-stack tyk-stack ./tyk-stack \
  --set "global.license.dashboard=$DASH_LICENSE" ...
```

The stack path also needs a MongoDB root password. You do not supply it: read it from the
secret that the MongoDB chart creates, as the workflow does.

### What a local run does not cover

Read a local pass as weaker evidence than a CI pass, for four reasons:

- CI runs the smoke tests against five Kubernetes versions, v1.26.13 through v1.30.0. A kind
  cluster with no pinned node image gives you whatever version kind currently defaults to,
  which may be one CI never tests. Pass `--image kindest/node:v1.30.0` to match.
- CI pins chart-testing to v3.3.0 and uses Helm 3. Package managers generally carry newer
  versions of both.
- The `no-securitycontext` job asserts that no pod renders `runAsUser` or `fsGroup`. Linting
  renders that values file but makes no such assertion.
- Both data-plane paths stay unrun without the `HYBRID_*` credentials.

### Troubleshooting

**An install produces no output at all.** If `helm install` against an `oci://` URL prints
nothing and creates no release, check your Docker credential helper before you suspect the
chart. Helm calls that helper before it pulls an OCI chart, and a wedged helper blocks Helm
with no error. Find which helper you use, then probe it:

```bash
grep credsStore ~/.docker/config.json
echo registry-1.docker.io | docker-credential-<helper> get
```

If the helper does not answer within a few seconds, restart Docker. The `--timeout` flag does
not help here, because it covers the Kubernetes wait and Helm never gets that far.

**An install times out on a first run.** The gateway image is large, and kind keeps its image
cache inside the node container. `kind delete cluster` discards that cache, so every fresh
cluster downloads the images again. Raise `--timeout` on a slow connection.
