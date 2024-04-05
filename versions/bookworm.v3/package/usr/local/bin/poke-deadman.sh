#!/usr/bin/env bash

## dumb bug with how $1 is passed? hardcoded ver
function get_apigateway_id_cache_key() {
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('APIGATEWAY_ID', b'').decode('utf-8')));"
}

function get_apikey_value_cache_key() {
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('APIKEY_VALUE', b'').decode('utf-8')));"
}

APIGATEWAY_ID=$(get_apigateway_id_cache_key)
APIKEY_VALUE=$(get_apikey_value_cache_key)

APIKEY_VALUE_LENGTH=${#APIKEY_VALUE}
NUM_ASTERISKS=$((APIKEY_VALUE_LENGTH-4))
ASTERISKS=$(printf '%*s' "$NUM_ASTERISKS" | tr ' ' '*')

if [[ ! -z $APIGATEWAY_ID ]] && [[ ! -z $APIKEY_VALUE ]]; then
  echo "curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H \"x-api-key: ${ASTERISKS}${APIKEY_VALUE: -4}\" -H \"Content-Type: application/json\""
  curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H "x-api-key: ${APIKEY_VALUE}" -H "Content-Type: application/json"
else
  echo "poke-deadman.sh didn't run: APIGATEWAY_ID=$APIGATEWAY_ID, APIKEY_VALUE=$APIKEY_VALUE"
fi