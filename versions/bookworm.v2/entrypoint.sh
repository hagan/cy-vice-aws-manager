#!/bin/sh
set -e

echo "Welcome to AWS resource manager"
echo "RUNSHELL=$RUNSHELL"
echo "/run/nginx/node-nextjs.socket?"

# Take our environment variables from docker and insert into .env.local
test -d /usr/local/src/awsmgr-ui && echo "NODE_SOCK=$NODE_SOCK" > /usr/local/src/awsmgr-ui/.env.local

if [ ! -z "$RUNSHELL" && "$RUNSHELL" == "yes" ]; then
  /usr/bin/bash
else
  test -f /usr/bin/supervisord && /usr/bin/supervisord -c /etc/supervisord.conf || /usr/bin/bash
fi