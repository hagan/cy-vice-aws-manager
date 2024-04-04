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

if [ ! -z ${APIGATEWAY_NAME} ]; then
  export APIGATEWAY_NAME
else
  echo "setting APIGATEWAY_NAME='cy-awsmgr-gateway'"
  export APIGATEWAY_NAME='cy-awsmgr-gateway'
fi

if [ ! -z ${APIGATEWAY_API_KEY_NAME} ]; then
  echo "APIGATEWAY_API_KEY_NAME = '${APIGATEWAY_API_KEY_NAME}'"
else
  >&2 echo "ERROR: Provided APIGATEWAY_API_KEY_NAME var was empty"
  export APIGATEWAY_API_KEY_NAME='VICE_DEMO_ACCESSKEY'
  echo "Using APIGATEWAY_API_KEY_NAME='${VICE_DEMO_ACCESSKEY}'"
fi

if [[ ! -z ${APIGATEWAY_STAGE} ]]; then
  echo "APIGATEWAY_STAGE = '${APIGATEWAY_STAGE}'"
else
  echo "WARNING: APIGATEWAY_STAGE var was empty"
  export APIGATEWAY_STAGE='dev'
  echo "Using APIGATEWAY_STAGE='${APIGATEWAY_STAGE}'"
fi

# Take our environment variables from docker and insert into .env.local
#test -d /usr/local/src/awsmgr-ui && echo "NODE_SOCK=$NODE_SOCK" > /usr/local/src/awsmgr-ui/.env.local

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