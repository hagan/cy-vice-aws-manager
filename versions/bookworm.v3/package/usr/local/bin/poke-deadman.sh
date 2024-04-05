#!/usr/bin/env bash

function get_cache_key() {
    ## only works if pymemcache is available / install systemwide
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('$1', b'').decode('utf-8')));"
}

APIGATEWAY_ID=$(get_cache_key 'APIGATEWAY_ID')
APIKEY_VALUE=$(get_cache_key 'APIKEY_VALUE')

APIKEY_VALUE_LENGTH=${#APIKEY_VALUE}
NUM_ASTERISKS=$((APIKEY_VALUE_LENGTH-4))
ASTERISKS=$(printf '%*s' "$NUM_ASTERISKS" | tr ' ' '*')

if [[ ! -z $APIGATEWAY_ID ]] && [[ ! -z $APIKEY_VALUE ]]; then
  echo "curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H \"x-api-key: ${ASTERISKS}${APIKEY_VALUE: -4}\" -H \"Content-Type: application/json\""
  curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H "x-api-key: ${APIKEY_VALUE}" -H "Content-Type: application/json"
fi