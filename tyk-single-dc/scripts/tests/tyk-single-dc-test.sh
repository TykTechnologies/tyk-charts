apk --no-cache add curl jq

TYK_DB_ADDR="${TYK_DB_PROTO}://${TYK_DB_SVC}.${TYK_POD_NAMESPACE}.svc.cluster.local:${TYK_DB_LISTENPORT}"

checkGateway() {
  count=0
  while [ $count -le 10 ]
  do
    healthCheck="$(curl --fail-with-body -sS ${TYK_DB_ADDR}/hello)"

    redisStatus=$(echo "${healthCheck}" | jq -r '.details.redis.status')
    if [[ "${redisStatus}" != "pass" ]]
    then
      echo "Redis is not ready"
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    dashStatus=$(echo "${healthCheck}" | jq -r '.status')
    if [[ "${dashStatus}" != "ok" ]]
    then
      echo "Dashboard is ready"
      echo "${healthCheck}"
      count=$((count+1))
      sleep 2
      continue
    fi

    break
  done

  if [[ $count -ge 10 ]]
  then
    echo "All components required for the Tyk Tyk single dc to work are NOT available"
  else
    echo "All components required for the Tyk Tyk single dc to work are available"
  fi
}

main() {
  checkGateway
  echo "Tests passed"
}

main