TYK_GW_ADDR="${TYK_GW_PROTO}://${TYK_GW_SVC}.${TYK_POD_NAMESPACE}.svc:${TYK_GW_LISTENPORT}"
TYK_GW_SECRET=${TYK_GW_SECRET}

checkGateway() {
  count=0
  while [ $count -le 10 ]
  do
    healthCheck="$(curl -sS ${TYK_GW_ADDR}/hello --connect-timeout 5)"
    result=$(echo "${healthCheck}" | jq -r '.details.redis.status')

    if [[ "${result}" != "pass" ]]
    then
      echo "Redis is not ready, healthCheck: ${healthCheck}."
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    break
  done

  if [[ $count -ge 10 ]]
  then
    echo "All components required for the Tyk Gateway to work are NOT available"
  else
    echo "All components required for the Tyk Gateway to work are available"
  fi
}

createKeylessAPI() {
    curl --fail-with-body -sS -H "x-tyk-authorization: ${TYK_GW_SECRET}" -H "Content-Type: application/json" -X POST \
      -d '{
        "name": "Hello-World",
        "use_keyless": true,
        "api_id": "random",
        "version_data": {
          "not_versioned": true,
          "versions": {
            "Default": {
              "name": "Default",
              "use_extended_paths": true
            }
          }
        },
        "proxy": {
          "listen_path": "/hello-world/",
          "target_url": "http://httpbin.org:8080/",
          "strip_listen_path": true
        },
        "active": true
    }' ${TYK_GW_ADDR}/tyk/apis

    if [[ $? -ne 0 ]]; then
      echo "fail to create API"
      exit 1
    fi

    reloadGateway
    echo "API is created successfully"
}

createKey() {
    curl --fail-with-body -X POST -H "x-tyk-authorization: ${TYK_GW_SECRET}" \
      -s \
      -H "Content-Type: application/json" \
      -X POST \
      -d '{
        "allowance": 1000,
        "rate": 1000,
        "per": 1,
        "expires": -1,
        "quota_max": -1,
        "org_id": "1",
        "quota_renews": 1449051461,
        "quota_remaining": -1,
        "quota_renewal_rate": 60,
        "access_rights": {
          "random": {
            "api_id": "random",
            "api_name": "Hello-World",
            "versions": ["Default"]
          }
        },
        "meta_data": {}
      }' ${TYK_GW_ADDR}/tyk/keys/create

    if [[ $? -ne 0 ]]; then
      echo "failed to create Policy"
      exit 1
    fi

    echo "Policy is created successfully"

    reloadGateway
}

reloadGateway() {
  curl --fail-with-body -H "x-tyk-authorization: ${TYK_GW_SECRET}" -s ${TYK_GW_ADDR}/tyk/reload/group

  if [[ $? -ne 0 ]]; then
    echo "failed to reload Gateway"
    exit 1
  fi

  echo "Tyk Gateway is reloaded successfully"
}

clean() {
  count=0
  while [ $count -le 10 ]
  do
    echo "Cleaning system, attempt: $count"
    curl --fail-with-body -X DELETE -H "x-tyk-authorization: ${TYK_GW_SECRET}" -s ${TYK_GW_ADDR}/tyk/apis/random

    if [[ $? -ne 0 ]]; then
      echo "failed to delete API"
    fi

    count=$((count+1))

    sleep 2
    reloadGateway
  done

  echo "API deleted successfully"
}

main() {
  checkGateway
  createKeylessAPI
  createKey
  clean
  echo "Tests passed"
}

main