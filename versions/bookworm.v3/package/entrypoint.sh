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

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo -e "'AWS_ACCESS_KEY_ID' is unset!\n"
else
  : # noop
  # echo "Captured AWS_ACCESS_KEY_ID = '${AWS_ACCESS_KEY_ID}'"
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo -e "'AWS_SECRET_ACCESS_KEY' environment variable is unset!\n"
else
  : # noop
  # echo "Captured AWS_SECRET_ACCESS_KEY = '${AWS_SECRET_ACCESS_KEY//?/*}'"
fi

if [ -z "${AWS_SESSION_TOKEN}" ]; then
  echo -e "'AWS_SESSION_TOKEN' environment variable is unset!\n"
else
  : # noop
  # echo "Captured AWS_SESSION_TOKEN = '${AWS_SESSION_TOKEN//?/*}'"
fi

if [ ! -z "${AWS_KMS_KEY}" ]; then
  : # noop
  # echo "Captured AWS_KMS_KEY = '${AWS_KMS_KEY//?/*}'"
fi

if [ -z "${AWS_DEFAULT_REGION}" ]; then
  export AWS_DEFAULT_REGION='us-west-2'
else
  echo "Captured AWS_DEFAULT_REGION = '${AWS_DEFAULT_REGION}'"
fi

if [ -z "${AWS_DEFAULT_PROFILE}" ]; then
  export AWS_DEFAULT_PROFILE='default'
else
  : # noop
  # echo "Captured AWS_DEFAULT_PROFILE = '${AWS_DEFAULT_PROFILE}'"
fi

if [ ! -z ${EXPRESS_SOCKET_FILE} ]; then
  echo "Captured EXPRESS_SOCKET_FILE = '${EXPRESS_SOCKET_FILE}'"
fi

if [ ! -z ${GUNICORN_SOCKET_FILE} ]; then
  echo "Captured GUNICORN_SOCKET_FILE = '${GUNICORN_SOCKET_FILE}'"
fi

# export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_KMS_KEY AWS_DEFAULT_REGION 

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