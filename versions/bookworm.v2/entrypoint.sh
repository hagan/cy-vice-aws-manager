#!/bin/sh
set -e

if [ ! -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo -e "WARNING: 'AWS_ACCESS_KEY_ID' is unset!\n"
  export AWS_ACCESS_KEY_ID=
fi

if [ ! -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo -e "WARNING: 'AWS_SECRET_ACCESS_KEY' is unset!\n"
  export AWS_SECRET_ACCESS_KEY=
fi

if [ ! -z "${AWS_SESSION_TOKEN}" ]; then
  export AWS_SESSION_TOKEN=
fi

if [ ! -z "${AWS_KMS_KEY}" ]; then
  export AWS_KMS_KEY=
fi

if [ ! -z "${AWS_DEFAULT_REGION}" ]; then
  export AWS_DEFAULT_REGION='us-west-2'
fi

if [ ! -z "${AWS_DEFAULT_PROFILE}" ]; then
  export AWS_DEFAULT_PROFILE=
fi

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_KMS_KEY AWS_DEFAULT_REGION AWS_DEFAULT_PROFILE

# Take our environment variables from docker and insert into .env.local
#test -d /usr/local/src/awsmgr-ui && echo "NODE_SOCK=$NODE_SOCK" > /usr/local/src/awsmgr-ui/.env.local

## launch shell
if [ ! -z "$RUNSHELL" ] && [ "$RUNSHELL" == "yes" ]; then
  /usr/bin/bash
else
  /usr/bin/supervisord -c /etc/supervisord.conf || /usr/bin/bash
fi