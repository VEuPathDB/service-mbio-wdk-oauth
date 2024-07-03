#!/bin/bash

mkdir -p /opt/logs/tomcat /opt/logs/nginx \
    && /opt/bin/configureSite.sh /opt/files /var/www/local.microbiomedb.org \
    && /opt/bin/configureOauth.sh \
    && /opt/apache-tomcat/bin/startup.sh \
    && (echo "Waiting for OAuth..."; sleep 10) \
    && cp /var/www/local.microbiomedb.org/gus_home/config/mbio.xml /opt/apache-tomcat/conf/Catalina/localhost \
    && echo "WDK webapp deployed.  Starting up nginx" \
    && nginx \
    && echo "Services running..." \
    && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
