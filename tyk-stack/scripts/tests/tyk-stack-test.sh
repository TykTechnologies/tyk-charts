TYK_GW_ADDR="${TYK_GW_PROTO}://${TYK_GW_SVC}.${TYK_POD_NAMESPACE}.svc:${TYK_GW_LISTENPORT}"
TYK_GW_SECRET=${TYK_GW_SECRET}

checkGateway() {
  count=0
  while [ $count -le 30 ]
  do
    healthCheck="$(curl --fail-with-body -sS ${TYK_GW_ADDR}/hello --connect-timeout 5)"

    redisStatus=$(echo "${healthCheck}" | jq -r '.details.redis.status')
    if [[ "${redisStatus}" != "pass" ]]
    then
      echo "Redis is not ready, healthCheck: ${healthCheck}."
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    dashStatus=$(echo "${healthCheck}" | jq -r '.details.dashboard.status')
    if [[ "${dashStatus}" != "pass" ]]
    then
      echo "Dashboard is ready"
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    break
  done

  if [[ $count -ge 30 ]]
  then
    echo "All components required for the Tyk stack to work are NOT available"
    exit 1
  else
    echo "All components required for the Tyk stack to work are available"
  fi
}

main() {
  checkGateway
  echo "Tests passed"
}

main