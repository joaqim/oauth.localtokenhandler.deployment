#!/bin/bash

###############################################################
# A script to run the Token Handler in a local Docker container
###############################################################

#
# Set the current folder if this script is called from another script
#
cd "$(dirname "${BASH_SOURCE[0]}")"
BUSINESS_API_URL='https://api.mycompany.com:445/api'

#
# Do some string manipulation to update kong.yml with the runtime value for the Business API URL
#
ESCAPED_URL=$(echo $BUSINESS_API_URL | sed "s/\//\\\\\//g")
KONG_YML_DATA=$(cat ./apigateway/kong.template.yml)
KONG_YML_DATA=$(sed "s/BUSINESS_API_URL/$ESCAPED_URL/g" <<< "$KONG_YML_DATA")
echo "$KONG_YML_DATA" > ./apigateway/kong.yml

#
# Run the Docker compose network
#
docker compose --project-name localtokenhandler up --force-recreate
if [ $? -ne 0 ]; then
  echo "Problem encountered starting Docker components"
  exit 1
fi