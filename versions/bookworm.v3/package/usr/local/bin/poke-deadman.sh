#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

function get_cache_key() {
    ## only works if pymemcache is available / install systemwide
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('$1', b'').decode('utf-8')));"
}

APIGATEWAY_ID=$(get_cache_key 'APIGATEWAY_ID')
APIKEY_VALUE=$(get_cache_key 'APIKEY_VALUE')

if [[ ! -z $APIGATEWAY_ID ]] && [[ ! -z $APIKEY_VALUE ]]; then
  #echo "curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H \"x-api-key: ${APIKEY_VALUE}\" -H \"Content-Type: application/json\""
  curl -X POST https://$APIGATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/deadman -H "x-api-key: ${APIKEY_VALUE}" -H "Content-Type: application/json"
fi