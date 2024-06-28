#!/bin/bash

mkdir -p /opt/logs/tomcat /opt/logs/nginx \
    && /opt/bin/configureSite.sh /opt/files /var/www/local.microbiomedb.org \
    && cp /var/www/local.microbiomedb.org/gus_home/config/mbio.xml /opt/apache-tomcat/conf/Catalina/localhost \
    && /opt/apache-tomcat/bin/startup.sh \
    && nginx \
    && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
