#!/bin/bash
################################################################################
##
## buildMountedDirs.sh
##
## This script should be run on machines which will host the Dockerized
## WDK/OAuth/EDA service stack.  The directories created are the default
## locations for mount points needed by the stack and should house
## additional config files, download files, and logs of the running services.
##
################################################################################

mkdir -p /var/www/Common

cd /var/www/

mkdir Common/apiSiteFilesMirror
mkdir Common/apiSiteFilesMirror/webServices
mkdir Common/apiSiteFilesMirror/downloadSite

mkdir Common/userDatasets

mkdir Common/secrets

# The following are config files required by WDK/OAuth (see docs)
#Common/secrets/cacerts
#Common/secrets/oauth-keys.pkcs12
#Common/secrets/wdkSecretKey.txt

mkdir Common/logs
mkdir Common/logs/nginx
mkdir Common/logs/tomcat

mkdir Common/persistentData
mkdir Common/persistentData/minio

mkdir Common/tmp
mkdir Common/tmp/wdkStepAnalysisJobs
