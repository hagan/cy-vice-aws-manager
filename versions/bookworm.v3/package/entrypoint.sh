#!/bin/sh
set -e

echo "DOCKER VERSION INFO"
cat /etc/docker-image-ver

# echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | /usr/bin/envsubst > /home/cyverse/.irods/irods_environment.json
# chown cyverse:cyverse /home/cyverse/.irods/irods_environment.json
# echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | /usr/bin/envsubst > /home/node/.irods/irods_environment.json
# chown node:node /home/node/.irods/irods_environment.json
# echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | /usr/bin/envsubst > /home/gunicorn/.irods/irods_environment.json
# chown gunicorn:gunicorn /home/gunicorn/.irods/irods_environment.json

if [ -z "${AWS_ACCOUNT_ID}" ]; then
  set +e
  _ACCOUNT_ID=$(/usr/local/bin/aws sts get-caller-identity --query "Account" --output text)
  RETVAL=$?
  set -e
  if [ ${RETVAL} -eq 0 ]; then
    export AWS_ACCOUNT_ID=${_ACCOUNT_ID}
  else
    >&2 echo "ERROR: Failed to find AWS_ACCOUNT_ID"
    export AWS_ACCOUNT_ID=
  fi
fi
echo "AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID//[^0-9]/}" >> /etc/environment

if [ -z "${AWS_CREDENTIAL_EXPIRATION}" ]; then
  export AWS_CREDENTIAL_EXPIRATION=
fi

if [ -z "${AWS_DEFAULT_REGION}" ]; then
  export AWS_DEFAULT_REGION='us-west-2'
else
  echo "Captured AWS_DEFAULT_REGION = '${AWS_DEFAULT_REGION}'"
fi

if [ -z "${AWS_KMS_KEY}" ]; then
  export AWS_KMS_KEY=
fi

## REQUIRED!

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo -e "ERROR: 'AWS_ACCESS_KEY_ID' is unset!\n"
else
  : # noop
  # echo "Captured AWS_ACCESS_KEY_ID = '${AWS_ACCESS_KEY_ID}'"
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo -e "ERROR: 'AWS_SECRET_ACCESS_KEY' environment variable is unset!\n"
else
  : # noop
  # echo "Captured AWS_SECRET_ACCESS_KEY = '${AWS_SECRET_ACCESS_KEY//?/*}'"
fi

if [ -z "${AWS_SESSION_TOKEN}" ]; then
  echo -e "ERROR: 'AWS_SESSION_TOKEN' environment variable is unset!\n"
else
  : # noop
  # echo "Captured AWS_SESSION_TOKEN = '${AWS_SESSION_TOKEN//?/*}'"
fi

## Paths to our socket files

if [ ! -z ${EXPRESS_SOCKET_FILE} ]; then
  echo "Captured EXPRESS_SOCKET_FILE = '${EXPRESS_SOCKET_FILE}'"
fi

if [ ! -z ${GUNICORN_SOCKET_FILE} ]; then
  echo "Captured GUNICORN_SOCKET_FILE = '${GUNICORN_SOCKET_FILE}'"
fi

## using aws cli pull down the api key?

if [ ! -z ${AWSGATEWAY_API_KEY_NAME}]; then
  echo "Captured AWSGATEWAY_API_KEY_NAME = '${AWSGATEWAY_API_KEY_NAME}'"
else
  APIGATEWAY_API_KEY_NAME='VICE_DEMO_ACCESSKEY'
  APIGATEWAY_ID=$(aws apigateway get-rest-apis | jq -r -c ".items[] | if .name == \"${AWSGATEWAY_API_KEY_NAME}\" then .id else empty end")
fi


if [[ -z $APIGATEWAY_ID ]] ; then
   >&2 echo "ERROR: APIGATEWAY_ID returned empty!"
else
  echo "APIGATEWAY_ID: ${APIGATEWAY_ID}"
  APIKEY_ID=$(aws apigateway get-api-keys --name-query "${APIGATEWAY_API_KEY_NAME}" | jq -r -c '.items[0].id')
fi

if [[ -z $APIKEY_ID ]] ; then
   >&2 echo "ERROR: APIKEY_ID returned is empty!"
else
  echo "APIKEY_ID: ${APIKEY_ID}"
  AWSKEY_RAW=$(aws apigateway get-api-key --api-key $APIKEY_ID --include-value)
  if [[ $? -eq 0 ]]; then
    APIKEY_VALUE=$(echo $AWSKEY_RAW | jq -r -c '.value')
    APIKEY_NAME=$(echo $AWSKEY_RAW | jq -r -c '.name')
    echo "APIKEY_VALUE = ${APIKEY_VALUE}"
    echo "APIKEY_NAME = ${APIKEY_NAME}"
  fi
fi


# export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_KMS_KEY AWS_DEFAULT_REGION

# Take our environment variables from docker and insert into .env.local
#test -d /usr/local/src/awsmgr-ui && echo "NODE_SOCK=$NODE_SOCK" > /usr/local/src/awsmgr-ui/.env.local

## test we can access aws with credentials

  # AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}' \
  # AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}' \
  # AWS_SESSION_TOKEN='${AWS_SESSION_TOKEN}' \


## THIS CANNOT WORK... Must start after memcached is running...
# if [[ -z ${SKIP_AUTH_TEST} ]]; then
#   /usr/bin/su --whitelist-environment=AWS_ACCOUNT_ID,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_DEFAULT_REGION,AWS_CREDENTIAL_EXPIRATION - cyverse -c " \
#   /home/cyverse/envs/flask-env/bin/awsmgr renew-token \
#   --env AWS_ACCOUNT_ID \
#   --env AWS_ACCESS_KEY_ID \
#   --env AWS_SECRET_ACCESS_KEY \
#   --env AWS_SESSION_TOKEN \
#   --env AWS_DEFAULT_REGION \
#   --env AWS_CREDENTIAL_EXPIRATION \
#   --skip-memcached \
#   --fakeit"
# fi

## launch shell
if [ ! -z "$RUNSHELL" ] && [ "$RUNSHELL" == "yes" ]; then
  exec /usr/bin/bash
else
  ## WORKAROUND -> https://github.com/moby/moby/issues/40553 (this gets set in vice Dockerfile)
  setfacl \
      -m u:cyverse:rwx,g:cyverse:rwx \
      -m d:cyverse:rwx,g:cyverse:rwx \
      -m o::r-x \
      -m d:o::r-x /usr/local/var && { echo "-36-"; } || { echo "ERROR -36-"; exit 1; }
  setfacl \
      -m u:cyverse:rwx,g:cyverse:rwx \
      -m d:cyverse:rwx,g:cyverse:rwx \
      -m o::--- \
      -m d:o::--- /usr/local/var/pulumi && { echo "-37-"; } || { echo "ERROR -37-"; exit 1; }
  ## END OF WORKAROUND
  exec /usr/bin/supervisord -c /etc/supervisord.conf || /usr/bin/bash
fi