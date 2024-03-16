#!/usr/bin/env bash

MEMCACHED_PORT=11212

## set our memcache with our aws details!

function get_cache_key() {
    ## only works if pymemcache is available / install systemwide
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('$1', b'').decode('utf-8')));"
}

while true; do
  sleep 10
  _AWS_ACCESS_KEY_ID=$(get_cache_key 'AWS_ACCESS_KEY_ID')
  # _AWS_ACCESS_KEY_ID=$(echo "get AWS_ACCESS_KEY_ID" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
  echo "AWS_ACCESS_KEY_ID => $AWS_ACCESS_KEY_ID vs $_AWS_ACCESS_KEY_ID"
  _AWS_ACCOUNT_ID=$(get_cache_key 'AWS_ACCOUNT_ID')
  echo "AWS_ACCOUNT_ID => $AWS_ACCOUNT_ID vs $_AWS_ACCOUNT_ID"
done