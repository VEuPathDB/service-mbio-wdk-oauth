#!/bin/bash

# note locations of war and config file (placed there by Dockerfile)
unmodifiedConfig=/opt/OAuthSampleConfig-Mbio.json
warFile=/opt/apache-tomcat/webapps/oauth.war

# make config file from sample. Put it in a WEB-INF directory. Later that WEB-INF directory
# and configuration file will be merged (jar -u) in to the war.

cd /opt
rm -rf "WEB-INF"
mkdir "WEB-INF"

# verify required env vars
verify() {
  name=$1
  value=$2
  if [ "$value" == "" ]; then
    echo "Environment variable '$name' is required."
    exit 1
  fi
}

verify "WDK_OAUTH_CLIENT_ID" "${WDK_OAUTH_CLIENT_ID}"
verify "WDK_OAUTH_CLIENT_SECRET" "${WDK_OAUTH_CLIENT_SECRET}"
verify "SERVICE_OAUTH_CLIENT_ID" "${SERVICE_OAUTH_CLIENT_ID}"
verify "SERVICE_OAUTH_CLIENT_SECRET" "${SERVICE_OAUTH_CLIENT_SECRET}"
verify "ACCT_DB_CONNECTION_URL" "${ACCT_DB_CONNECTION_URL}"
verify "ACCT_DB_LOGIN" "${ACCT_DB_LOGIN}"
verify "ACCT_DB_PASSWORD" "${ACCT_DB_PASSWORD}"
verify "OAUTH_SIGNING_KEY_STORE" "${OAUTH_SIGNING_KEY_STORE}"
verify "OAUTH_SIGNING_KEY_STORE_PW" "${OAUTH_SIGNING_KEY_STORE_PW}"
verify "OAUTH_DB_PLATFORM" "${OAUTH_DB_PLATFORM}"

echo "Configuring OAuth Service with:"
echo "AccountDB: ${ACCT_DB_CONNECTION_URL}"
echo "WDK Client ID: ${WDK_OAUTH_CLIENT_ID}"
echo "Service Client ID: ${SERVICE_OAUTH_CLIENT_ID}"
echo "DB Platform" "${OAUTH_DB_PLATFORM}"

# DO NOT ECHO LOGIN CREDENTIALS TO STDOUT (set +x)
set +x

echo "Configuring OAuth..."
echo "Key store: $OAUTH_SIGNING_KEY_STORE"

jq \
  --arg db_url $ACCT_DB_CONNECTION_URL \
  --arg db_login $ACCT_DB_LOGIN \
  --arg db_password $ACCT_DB_PASSWORD \
  --arg signing_key_store $OAUTH_SIGNING_KEY_STORE \
  --arg signing_key_store_pw $OAUTH_SIGNING_KEY_STORE_PW \
  --arg wdk_client_id $WDK_OAUTH_CLIENT_ID \
  --arg wdk_client_secret $WDK_OAUTH_CLIENT_SECRET \
  --arg service_client_id $SERVICE_OAUTH_CLIENT_ID \
  --arg service_client_secret $SERVICE_OAUTH_CLIENT_SECRET \
  --arg oauth_db_platform $OAUTH_DB_PLATFORM '
  . |
  (.allowedClients[] | select(.clientId == $wdk_client_id) |  .clientSecrets) = [$wdk_client_secret] |
  (.allowedClients[] | select(.clientId == $wdk_client_id) |  .clientDomains) = ["*.amoebadb.org","*.apidb.org","*.cryptodb.org","*.eupathdb.org","*.fungidb.org","*.giardiadb.org","*.hostdb.org","*.microsporidiadb.org","*.orthomcl.org","*.piroplasmadb.org","*.plasmodb.org","*.schistodb.net","*.toxodb.org","*.trichdb.org","*.tritrypdb.org","*.clinepidb.org","*.microbiomedb.org","*.vectorbase.org","*.veupathdb.org"] |
  (.allowedClients[] | select(.clientId == $service_client_id) |  .clientSecrets) = [$service_client_secret] |
  (.allowedClients[] | select(.clientId == $service_client_id) |  .clientDomains) = ["*.amoebadb.org","*.apidb.org","*.cryptodb.org","*.eupathdb.org","*.fungidb.org","*.giardiadb.org","*.hostdb.org","*.microsporidiadb.org","*.orthomcl.org","*.piroplasmadb.org","*.plasmodb.org","*.schistodb.net","*.toxodb.org","*.trichdb.org","*.tritrypdb.org","*.clinepidb.org","*.microbiomedb.org","*.vectorbase.org","*.veupathdb.org"] |
  .keyStoreFile = $signing_key_store |
  .keyStorePassPhrase = $signing_key_store_pw |
  .authenticatorConfig.login = $db_login | 
  .authenticatorConfig.password = $db_password |
  .authenticatorConfig.connectionUrl = $db_url |
  .authenticatorConfig.platform = $oauth_db_platform
' \
$unmodifiedConfig \
> "WEB-INF/OAuthConfig.json"

rm -f WEB-INF/OAuthSampleConfig.json
set -x

# The OAuth2Server configuration file was created and added to WEB-INF in the previous Build step of this job. 
# Now copy the contents of WEB-INF into the war file before deployment.

jar -uf $warFile WEB-INF

