#!/bin/sh
set -e

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo -e "WARNING: 'AWS_ACCESS_KEY_ID' is unset!\n"
  AWS_ACCESS_KEY_ID=
else
  echo "Captured AWS_ACCESS_KEY_ID = '${AWS_ACCESS_KEY_ID}'"
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo -e "WARNING: 'AWS_SECRET_ACCESS_KEY' is unset!\n"
  AWS_SECRET_ACCESS_KEY=
else
  echo "Captured AWS_SECRET_ACCESS_KEY = '${AWS_SECRET_ACCESS_KEY//?/*}'"
fi

if [ -z "${AWS_SESSION_TOKEN}" ]; then
  AWS_SESSION_TOKEN=
else
  echo "Captured AWS_SESSION_TOKEN = '${AWS_SESSION_TOKEN//?/*}'"
fi

if [ -z "${AWS_KMS_KEY}" ]; then
  AWS_KMS_KEY=
else
  echo "Captured AWS_KMS_KEY = '${AWS_KMS_KEY//?/*}'"
fi

if [ -z "${AWS_DEFAULT_REGION}" ]; then
  AWS_DEFAULT_REGION='us-west-2'
else
  echo "Captured AWS_DEFAULT_REGION = '${AWS_DEFAULT_REGION}'"
fi

if [ -z "${AWS_DEFAULT_PROFILE}" ]; then
  AWS_DEFAULT_PROFILE=
else
  echo "Captured AWS_DEFAULT_PROFILE = '${AWS_DEFAULT_PROFILE}'"
fi

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_KMS_KEY AWS_DEFAULT_REGION AWS_DEFAULT_PROFILE

# Take our environment variables from docker and insert into .env.local
#test -d /usr/local/src/awsmgr-ui && echo "NODE_SOCK=$NODE_SOCK" > /usr/local/src/awsmgr-ui/.env.local

## launch shell
if [ ! -z "$RUNSHELL" ] && [ "$RUNSHELL" == "yes" ]; then
  exec /usr/bin/bash
else
  exec /usr/bin/supervisord -c /etc/supervisord.conf || /usr/bin/bash
fi