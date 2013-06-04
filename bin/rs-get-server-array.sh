#!/bin/sh -e

# rs-get-server-array <server_array_id>

. "$HOME/.rightscale/rs_api_config.sh"
. "$HOME/.rightscale/rs_api_creds.sh"

if [ "$1" ]; then
     array_id="/$1"
fi

url="https://my.rightscale.com/api/acct/$rs_api_account_id/server_arrays$array_id"
echo "GET: $url"
api_result=$(curl -s -H "X-API-VERSION: $rs_api_version" -b "$rs_api_cookie" "$url")
echo "$api_result"
