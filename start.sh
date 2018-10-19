#!/bin/bash

declare -A APPENVS

# base envs
APPENVS[APP_NAME]=test_container
APPENVS[APP_PATH]=./app/
APPENVS[IP_COUNTER]=2 # 2-254 (or 'auto')

if [ ${APPENVS["IP_COUNTER"]} == 'auto' ]; then
  echo 'TODO'
  exit 1
  function getNextIp() {
    ping -c 1 -W 1 172.20.0.$1 > /dev/null

    if [ $? -eq 0 ]; then
      echo $(getNextIp `expr ${1} + 1`)
    else
      echo $1
    fi
  }

  APPENVS[IP_COUNTER]=$(getNextIp 2)
fi

# database envs
APPENVS[EXTERNAL_DB_PORT]=`expr ${APPENVS["IP_COUNTER"]} + 9000`
APPENVS[MYSQL_ROOT_PASSWORD]=my_secret_pw_shh
APPENVS[MYSQL_DATABASE]=test_db
APPENVS[MYSQL_USER]=devuser
APPENVS[MYSQL_PASSWORD]=devpass

# regenerate variables.env and export variables
rm -rf variables.env
touch variables.env
for K in "${!APPENVS[@]}"; do
  export ${K}="${APPENVS["$K"]}"

  echo "${K}=${APPENVS["$K"]}" >> variables.env
done

# regenerate docker-compose.yml
rm -rf docker-compose.yml
envsubst < "docker-compose.template.yml" > "docker-compose.yml"

# launch dockers
echo
echo "Launch ${APP_NAME}"
echo
docker-compose up -d

# check if dockers are started
if [ ! $? -eq 0 ]; then
    exit $?
fi

# print web app link
echo
echo "LINK: http://172.20.0.${APPENVS["IP_COUNTER"]}:8000"
echo

exit 0
