#!/bin/bash

declare -A APPENVS

# base envs
APPENVS[APP_NAME]=test_container
APPENVS[APP_PATH]=./app/
APPENVS[EXTERNAL_WEB_PORT]=8315

# database envs
APPENVS[EXTERNAL_DB_PORT]=9906
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

exit $?
