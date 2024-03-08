#!/usr/bin/env bash

MEMCACHED_PORT=11212

## set our memcache with our aws details!

# storing for 60 seconds
echo -e "set AWS_ACCESS_KEY_ID 0 60 ${#AWS_ACCESS_KEY_ID}\r\n${AWS_ACCESS_KEY_ID}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
echo -e "set AWS_SECRET_ACCESS_KEY 0 60 ${#AWS_SECRET_ACCESS_KEY}\r\n${AWS_SECRET_ACCESS_KEY}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
echo -e "set AWS_SESSION_TOKEN 0 60 ${#AWS_SESSION_TOKEN}\r\n${AWS_SESSION_TOKEN}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
echo -e "set AWS_KMS_KEY 0 60 ${#AWS_KMS_KEY}\r\n${AWS_KMS_KEY}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
echo -e "set AWS_DEFAULT_REGION 0 60 ${#AWS_DEFAULT_REGION}\r\n${AWS_DEFAULT_REGION}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
echo -e "set AWS_DEFAULT_PROFILE 0 60 ${#AWS_DEFAULT_PROFILE}\r\n${AWS_DEFAULT_PROFILE}\r\n" | nc -q 0 localhost ${MEMCACHED_PORT}
while true; do
  sleep 10
  _AWS_ACCESS_KEY_ID=$(echo "get AWS_ACCESS_KEY_ID" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
  echo "AWS_ACCESS_KEY_ID => $AWS_ACCESS_KEY_ID vs $_AWS_ACCESS_KEY_ID"
done