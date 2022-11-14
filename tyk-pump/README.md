## Tyk Pump
This chart deploys the open source Tyk Pump. 

## Prerequisites
- Redis 
- Mongo/Postgres 


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
    helm show values tyk-pump > values.yaml
    ```

4. **Set redis connection details in values.yaml file:**

    In values.yaml file, set `redis.addr` and `redis.pass` with redis connection string and password respectively.

    Alternatively, you can set connection details during installation using `--set` flag.

5. **Set mongo/postgres connection details in values.yaml file:**

    In values.yaml file, set `backend` to `postgres` or `mongo`. If not set, `mongo` will be used by default. 

    The connection details for mongo/postgres can be set under `mongo` and `postgres` section respectively in values.yaml file. 


5. **Install helm chart**

    ```bash
    helm install pump tyk-pump -n tyk -f values.yaml
    ```