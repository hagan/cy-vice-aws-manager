#!/bin/sh
set -e

echo "Welcome to AWS resource manager"
echo "/run/nginx/node-nextjs.socket?"

# Take our environment variables from docker and insert into .env.local
echo "NODE_SOCK=$NODE_SOCK" > /usr/src/awsmgr-ui/.env.local

/usr/bin/supervisord -c /etc/supervisord.conf