TYK_GW_ADDR="${TYK_GW_PROTO}://${TYK_GW_SVC}.${TYK_POD_NAMESPACE}.svc:${TYK_GW_LISTENPORT}"
TYK_GW_SECRET=${TYK_GW_SECRET}

checkGateway() {
  count=0
  while [ $count -le 10 ]
  do
    healthCheck="$(curl --fail-with-body -sS ${TYK_GW_ADDR}/hello --connect-timeout 5)"

    redisStatus=$(echo "${healthCheck}" | jq -r '.details.redis.status')
    if [[ "${redisStatus}" != "pass" ]]
    then
      echo "Redis is not ready"
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    rpcStatus=$(echo "${healthCheck}" | jq -r '.details.rpc.status')
    if [[ "${rpcStatus}" != "pass" ]]
    then
      echo "RPC is not ready"
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    break
  done

  if [[ $count -ge 10 ]]
  then
    echo "All components required for the Tyk Data Plane to work are NOT available"
  else
    echo "All components required for the Tyk Data Plane to work are available"
  fi
}

main() {
  checkGateway
  echo "Tests passed"
}

main