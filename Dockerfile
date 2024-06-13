# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   Build Service & Dependencies
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM node:14.21.1-alpine3.15 AS node
FROM amazoncorretto:21-alpine3.15-jdk AS prep

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN apk upgrade --no-cache

RUN apk add --no-cache \
  bash sed gawk jq findutils coreutils \
  openssh rsync curl wget git ca-certificates \
  make build-base gcc \
  apache-ant maven \
  perl perl-utils perl-dev perl-yaml perl-xml-simple perl-xml-parser perl-xml-twig \
  python3 py3-pip py3-six py3-yaml ansible

RUN ln -sf python3 /usr/bin/python

ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV GITHUB_TOKEN=$GITHUB_TOKEN

WORKDIR /workspace

COPY bin bin

COPY project_home project_home

RUN git clone https://github.com/VEuPathDB/gus-site-build-deploy.git
RUN mkdir build

RUN bash ./gus-site-build-deploy/bin/veupath-package-website.sh \
      project_home \
      build \
      MicrobiomePresenters \
      gus-site-build-deploy/config/webapp.prop \
      mbio-site-artifact

RUN stat /workspace/build/mbio-site-artifact.tar.gz

RUN cd /opt \
    && wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz \
    && tar zxvf apache-tomcat-9.0.89.tar.gz \
    && mv apache-tomcat-9.0.89 apache-tomcat


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   Construct Runtime Container
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM amazoncorretto:21-alpine3.15-jdk

# runtime needs
RUN apk add --no-cache \
  bash sed gawk jq findutils coreutils \
  openssh rsync curl wget git ca-certificates \
  perl perl-utils perl-dev perl-yaml perl-xml-simple perl-xml-parser perl-xml-twig

# install nginx
COPY --from=prep /workspace/bin /opt/bin
RUN bash /opt/bin/installNginx.sh

# copy and set up tomcat
COPY --from=prep /opt/apache-tomcat /opt/apache-tomcat
RUN chmod 755 /opt/apache-tomcat/bin/*.sh

# copy and set up website artifact
RUN mkdir -p /var/www/site.microbiomedb.org
COPY --from=prep /workspace/build/mbio-site-artifact.tar.gz /var/www/site.microbiomedb.org
RUN stat /var/www/site.microbiomedb.org/mbio-site-artifact.tar.gz
RUN cd /var/www/site.microbiomedb.org && tar zxvf mbio-site-artifact.tar.gz

# set env
ENV GUS_HOME=/var/www/site.microbiomedb.org/gus_home
ENV PATH=$GUS_HOME/bin:$PATH
ENV CATALINA_HOME=/opt/apache-tomcat

EXPOSE 8080

CMD /opt/apache-tomcat/bin/startup.sh && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
