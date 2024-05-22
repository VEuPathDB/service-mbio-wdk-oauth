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
  make gcc openssh bash rsync git sed findutils coreutils curl wget gawk jq \
  perl perl-utils perl-dev expat expat-dev expat-static \
  apache-ant maven \
  python3 py3-pip py3-six py3-yaml ansible python2

RUN ln -sf python3 /usr/bin/python

RUN cpan install CPAN::DistnameInfo
RUN cpan install YAML
RUN cpan install XML::Simple
RUN cpan install XML::Parser
RUN cpan install XML::Twig

ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV GITHUB_TOKEN=$GITHUB_TOKEN

WORKDIR /workspace

COPY project_home project_home

RUN git clone https://github.com/VEuPathDB/gus-site-build-deploy.git
RUN mkdir build

RUN bash ./gus-site-build-deploy/bin/veupath-package-website.sh \
      project_home \
      build \
      MicrobiomePresenters \
      gus-site-build-deploy/config/webapp.prop

RUN cd /opt \
    && wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz \
    && tar zxvf apache-tomcat-9.0.89.tar.gz \
    && mv apache-tomcat-9.0.89 apache-tomcat


FROM amazoncorretto:21-alpine3.15-jdk

COPY --from=prep /opt/apache-tomcat /opt/apache-tomcat
COPY --from=prep /workspace/build /build

RUN mkdir /var/www/site.microbiomedb.org && cp /build/*.tar /var/www/site.microbiomedb.org && tar zxvf *.tar

ENV GUS_HOME=/var/www/site.microbiomedb.org/gus_home
ENV PATH=$GUS_HOME/bin:$PATH

EXPOSE 8080

CMD /opt/tomcat/bin/startup.sh
