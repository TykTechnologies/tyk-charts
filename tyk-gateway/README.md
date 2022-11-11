## Tyk Gateway
This chart deploys the open source Tyk Gateway.

## Prerequisites
Redis should already be installed or accessible by the gateway.


## Installation
1. **Clone repository:**
    ```
    git clone https://github.com/TykTechnologies/tyk-charts.git
    ```

2. **Create namespace:**
    ```
    kubectl create namespace tyk 
    ```

3. **Get default values file:**
    ```
    helm show values tyk-gateway > values.yaml
    ```

4. **Set redis connection details in values.yaml file:**

    In values.yaml file, set `redis.addr` and `redis.pass` with redis connection string and password respectively.

    Alternatively, you can set connection details during installation using `--set` flag.


5. **Install helm chart**

```bash
helm install tyk-gateway tyk-gateway -n tyk -f values.yaml
```

> **_NOTE_**: By default, Gateway runs as DaemonSet. If you are using more than a Node, please update Gateway kind to `Deployment` because multiple instances of gateways won't sync API Definition.