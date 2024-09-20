# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   Build Service & Dependencies
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM amazoncorretto:21-alpine3.17-jdk AS prep

# add needed build packages
RUN apk add --no-cache \
  bash sed gawk jq findutils coreutils \
  openssh rsync curl wget git ca-certificates \
  make build-base gcc \
  apache-ant maven \
  perl perl-utils perl-dev perl-yaml perl-xml-simple perl-xml-parser perl-xml-twig \
  nodejs npm

# put github cred args into the environment for scripts to use
ARG GITHUB_USERNAME
ARG GITHUB_TOKEN
ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV GITHUB_TOKEN=$GITHUB_TOKEN

WORKDIR /workspace

# clone build-and-deploy script repo
RUN git clone https://github.com/VEuPathDB/gus-site-build-deploy.git

# build_type determines how projects are pulled into this build
#   - a value of "local" will use the projects in project_home
#   - any other value will use the commits noted in the build.project.versions file
ARG BUILD_TYPE

# copy site code + project versions into container (should be checked out with cloneProjects.sh)
#   Note if you want to use versions but project_home is non-empty, you may not maximize docker cache usage
RUN mkdir /workspace/project_home
COPY build.projects.versions project_hom[e] project_home
COPY bin bin

# this will move build.projects.versions to /workspace
RUN bash bin/resolveBuildProjects.sh $BUILD_TYPE

# build the site
RUN mkdir build
RUN bash ./gus-site-build-deploy/bin/veupath-package-website.sh \
      project_home \
      build \
      MicrobiomePresenters \
      gus-site-build-deploy/config/webapp.prop \
      mbio-site-artifact
RUN stat /workspace/build/mbio-site-artifact.tar.gz

# clone OAuth project and build war
RUN cp -r project_home/OAuth2Server .
RUN cd /workspace/OAuth2Server && bash EuPathDB/bin/build.sh WEB-INF/OAuthConfig.json

# download Tomcat 9 and make needed modifications
RUN cd /opt \
    && wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz \
    && tar zxvf apache-tomcat-9.0.93.tar.gz \
    && mv apache-tomcat-9.0.93 apache-tomcat \
    && chmod 755 /opt/apache-tomcat/bin/*.sh \
    && mkdir -p /opt/apache-tomcat/conf/Catalina/localhost \
    && rm -rf /opt/apache-tomcat/webapps/docs /opt/apache-tomcat/webapps/examples /opt/apache-tomcat/webapps/manager /opt/apache-tomcat/webapps/host-manager \
    && curl -o /opt/apache-tomcat/lib/ojdbc11-23.4.0.24.05.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc11/23.4.0.24.05/ojdbc11-23.4.0.24.05.jar \
    && curl -o /opt/apache-tomcat/lib/postgresql-42.7.3.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar

# copy remaining setup files into container
COPY conf conf
COPY files files

# operations requiring bin and conf above
RUN cp /workspace/conf/tomcat-logging.properties /opt/apache-tomcat/conf/logging.properties
RUN bash /workspace/bin/installNginx.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   Construct Runtime Container
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM amazoncorretto:21-alpine3.17-jdk

# add needed runtime packages
RUN apk add --no-cache \
  bash sed gawk jq findutils coreutils \
  openssh rsync curl wget git ca-certificates \
  perl perl-utils perl-dev perl-yaml perl-xml-simple perl-xml-parser perl-xml-twig

# set time zone
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
    && echo "America/New_York" > /etc/timezone

# copy needed files
COPY --from=prep /workspace/bin /opt/bin
COPY --from=prep /workspace/conf /opt/conf
COPY --from=prep /workspace/files /opt/files

# install and configure nginx
COPY --from=prep /etc/apk/keys/nginx_signing.rsa.pub /etc/apk/keys
RUN bash /opt/bin/installNginx.sh
RUN cp /opt/conf/nginx.conf.alpine /etc/nginx/nginx.conf
RUN cp /opt/conf/nginx.default.conf.alpine /etc/nginx/conf.d/default.conf

# open nginx to external requests
EXPOSE 80

# copy tomcat
COPY --from=prep /opt/apache-tomcat /opt/apache-tomcat

# copy and set up website artifact
RUN mkdir -p /var/www/local.microbiomedb.org
COPY --from=prep /workspace/build/mbio-site-artifact.tar.gz /var/www/local.microbiomedb.org
RUN stat /var/www/local.microbiomedb.org/mbio-site-artifact.tar.gz
RUN cd /var/www/local.microbiomedb.org && tar zxvf mbio-site-artifact.tar.gz

# copy project versions file into accessible location
COPY --from=prep /workspace/build.projects.versions /var/www/local.microbiomedb.org/html

# copy oauth build artifacts
COPY --from=prep /workspace/OAuth2Server/EuPathDB/target/oauth.war /opt/apache-tomcat/webapps
COPY --from=prep /workspace/OAuth2Server/EuPathDB/src/main/webapp/WEB-INF/OAuthSampleConfig-Mbio.json /opt

# set env
ENV GUS_HOME=/var/www/local.microbiomedb.org/gus_home
ENV PATH=$GUS_HOME/bin:$PATH
ENV CATALINA_HOME=/opt/apache-tomcat

# configure webapps, start tomcat and nginx, then infinite loop until container interruption
CMD ["/opt/bin/startup.sh"]
