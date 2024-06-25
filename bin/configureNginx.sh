#!/bin/bash

echo "Copying /opt/conf/nginx.conf.alpine to /etc/nginx/nginx.conf"
cp /opt/conf/nginx.conf.alpine /etc/nginx/nginx.conf
echo "Copying /opt/conf/nginx.default.conf.alpine to /etc/nginx/conf.d/default.conf"
cp /opt/conf/nginx.default.conf.alpine /etc/nginx/conf.d/default.conf

exit 0

###  OLD STUFF  ###

if [ "$1" = "" ]; then
  echo
  echo "USAGE: configureNginx.sh <configFile>"
  echo
  exit 1
fi

configFile=$1

if [ ! -e $configFile ]; then
  echo "$configFile does not exist"
  exit 1
fi

# nginx uses different config dirs depending on distribution
configDirs=( \
  /usr/local/nginx/conf \
  /etc/nginx \
  /usr/local/etc/nginx \
)

# find the correct location and overwrite
for $configDir in "${configDirs[@]}"; do
  if [ -e $configDir/nginx.conf ]; then
    echo "Found nginx.conf in $configDir"
    ls -r $configDir
    echo "Overwriting $configDir/nginx.conf with passed configuration file"
    cp $configFile $configDir/nginx.conf
    exit 0
  fi
done
