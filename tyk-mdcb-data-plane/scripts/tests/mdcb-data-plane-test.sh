apk --no-cache add curl jq

TYK_GW_ADDR="${TYK_GW_PROTO}://${TYK_GW_SVC}.${TYK_POD_NAMESPACE}.svc.cluster.local:${TYK_GW_LISTENPORT}"
TYK_GW_SECRET=${TYK_GW_SECRET}

checkGateway() {
  healthCheck="$(curl --fail-with-body -sS ${TYK_GW_ADDR}/hello)"

  redisStatus=$(echo "${healthCheck}" | jq -r '.details.redis.status')
  if [[ "${redisStatus}" != "pass" ]]
  then
    echo "Redis is not ready"
    echo "${healthCheck}"
    exit 1
  fi

  rpcStatus=$(echo "${healthCheck}" | jq -r '.details.rpc.status')
  if [[ "${rpcStatus}" != "pass" ]]
  then
    echo "RPC is not ready"
    echo "${healthCheck}"
    exit 1
  fi


  echo "All components required for the Tyk MDCB Data Plane to work are available"
}

main() {
  checkGateway
  echo "Tests passed"
}

main