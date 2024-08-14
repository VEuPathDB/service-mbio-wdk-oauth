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
  log=/opt/logs/exit-catch.log
  echo 
  echo "Found nginx PID to be: $(cat /var/run/nginx.pid)" &> $log
  echo "Found tomcat PID to be: $(ps -ef | grep tomcat | grep -v grep | awk '{ print $1 }')" &>> $log
  echo "Shutting down servers..." &>> $log
  nginx -s stop &>> $log
  /opt/apache-tomcat/bin/shutdown.sh &>> $log
  for attempts in {1..20}; do
    nginxPid=$(cat /var/run/nginx.pid)
    tomcatPid=$(ps -ef | grep tomcat | grep -v grep | awk '{ print $1 }')
    echo "nginx PID = ${nginxPid}, tomcat PID = ${tomcatPid}" &>> $log
    if [ "$nginxPid" = "" ] && [ "$tomcatPid" = "" ]; then
      echo "Tomcat and nginx gracefully shut down." &>> $log
      exit 0
    fi
    sleep 2
  done
  echo "Tomcat and nginx shutdown will be forced." &>> $log
  exit 1
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
    && tail -f /dev/null & wait ${!}
