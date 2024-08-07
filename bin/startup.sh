#!/usr/bin/env bash

trap gracefulShutdown EXIT

awaitWebapp() {
  webapp=$1
  url=$2
  sleep 3
  echo "Waiting for $webapp, will check $url"
  for attempts in {1..20}; do
    status=$(curl --head --no-progress-meter $url | tac | tac | head -1 | awk '{ print $2 }')
    echo "$webapp attempt ${attempts}: Status is <$status> from $url"
    if [ "$status" = "200" ]; then
      echo "$webapp is responding."
      return 0
    fi
    sleep 3
  done
  echo "$webapp failed to start."
  return 1
}

gracefulShutdown() {
  echo "Shutting down application..." > /opt/logs/exit-catch.log
  nginx -s stop
  /opt/apache-tomcat/bin/shutdown.sh
  # give webapps a reasonable amount of time to shut down
  sleep 5
  exit
}

echo "Starting up WDK and OAuth services..." \
    && mkdir -p /opt/logs/tomcat /opt/logs/nginx \
    && /opt/bin/configureOauth.sh \
    && /opt/apache-tomcat/bin/startup.sh \
    && awaitWebapp OAuth "http://localhost:8080/oauth/discovery" \
    && echo "OAuth webapp deployed; Deploying WDK webapp..." \
    && /opt/bin/configureSite.sh /opt/files /var/www/local.microbiomedb.org \
    && cp /var/www/local.microbiomedb.org/gus_home/config/mbio.xml /opt/apache-tomcat/conf/Catalina/localhost \
    && awaitWebapp WDK "http://localhost:8080/mbio/service" \
    && echo "WDK webapp deployed.  Starting up nginx" \
    && nginx \
    && echo "Services running..." \
    && exec bash -c 'sleep infinity & wait'
