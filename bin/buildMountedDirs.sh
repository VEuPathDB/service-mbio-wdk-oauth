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

# check for input var existence
if [ "$1" = "" ]; then
  echo
  echo "USAGE: buildMountedDirs.sh <siteDataDir>"
  echo
  echo "   Typical input location is /var/www/Common"
  echo
  exit 1
fi

siteDataDir=$1

if [ ! -d $siteDataDir ]; then
  echo "Error: $siteDataDir does not exist"
  exit 2
fi

cd $siteDataDir
currentDir=$(pwd)

dirs=(\
  apiSiteFilesMirror \
  apiSiteFilesMirror/downloadSite \
  apiSiteFilesMirror/webServices \
  logs \
  logs/nginx \
  logs/tomcat \
  persistentData \
  persistentData/minio \
  persistentData/postgres \
  secrets \
  tmp \
  tmp/wdkStepAnalysisJobs \
  userDatasets \
)

for dir in "${dirs[@]}"; do
  echo "Creating $currentDir/$dir"
  mkdir -p $currentDir/$dir
done
