#!/bin/bash

##############################################################################
# A script to deploy Token Handler resources to a local Docker compose network
##############################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Download SSL certificates
#
rm -rf certs
git clone https://github.com/gary-archer/oauth.developmentcertificates ./certs
if [ $? -ne 0 ]; then
    echo 'Problem encountered downloading API certificates'
    exit 1
fi
cd certs
cd ..

#
# Download the Curity OAuth proxy plugin
#
rm -rf oauth-proxy-plugin
git clone https://github.com/curityio/kong-bff-plugin ./oauth-proxy-plugin
if [ $? -ne 0 ]; then
    echo 'Problem encountered downloading the Curity OAuth proxy plugin'
    exit 1
fi

#
# Download the main token handler API
#
rm -rf tokenhandlerapi
git clone https://github.com/gary-archer/oauth.tokenhandler.docker tokenhandlerapi
if [ $? -ne 0 ]; then
    echo 'Problem encountered downloading the Token Handler API'
    exit 1
fi
cd tokenhandlerapi

#
# Install API dependencies
#
rm -rf node_modules
npm install
if [ $? -ne 0 ]; then
  echo "Problem encountered installing the Token Handler API dependencies"
  exit 1
fi

#
# Build the token handler API's code
#
npm run buildRelease
if [ $? -ne 0 ]; then
  echo "Problem encountered building the Token Handler API code"
  exit 1
fi

#
# If the token handler calls a local API, this ensures that SSL trust works
# If also running a proxy tool such as Charles on the host, the proxy root CA may cause SSL trust problems
# To resolve this, set an environment variable that includes both the below CA and the proxy root CA
#
if [[ -z "$TOKEN_HANDLER_CA_CERTS" ]]; then
  cp ../certs/mycompany.ca.pem ./trusted.ca.pem
else
  cp $TOKEN_HANDLER_CA_CERTS ./trusted.ca.pem
fi

#
# Build the API's Docker container
#
docker build -f ./Dockerfile -t tokenhandler:v1 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the Token Handler API Docker container"
  exit 1
fi
