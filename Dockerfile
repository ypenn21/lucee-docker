## BUILD: 
#
#  if passing LUCEE_VERSION, it must include modifier, e.g. -SNAPSHOT, -RC, if there is one
#  if passing LUCEE_EXTENSIONS, the value has to be in double quotes
#
#  docker image build \
#    --build-arg LUCEE_VERSION=5.3.8.129-SNAPSHOT \
#    --build-arg LUCEE_ADMIN_PASSWORD=changeit \
#    --build-arg LUCEE_EXTENSIONS="3F9DFF32-B555-449D-B0EB5DB723044045;name=WebSocket" \
#    -t isapir/lucee-538 .
#
#  docker push isapir/lucee-538

## RUN:
#
#  WEBROOT=/webroot
#
#  docker container run -d --rm -p 8080:8080 --name lucee-8080 \
#    -v $WEBROOT:/srv/www/webapps/ROOT \
#    -e LUCEE_PRESERVE_CASE=true \
#    isapir/lucee-538

FROM tomcat:9-jdk11

# Set default LUCEE_VERSION
#   Override at build time with --build-arg LUCEE_VERSION=5.2.9.38-SNAPSHOT
ARG LUCEE_VERSION=5.3.7.47
ENV LUCEE_VERSION=${LUCEE_VERSION}

# Install optional Lucee extensions in the comma separated format {extension-id};name=X;label=XY;version=m.n
#   e.g. "3F9DFF32-B555-449D-B0EB5DB723044045;name=WebSocket"
ARG LUCEE_EXTENSIONS=
ENV LUCEE_EXTENSIONS=${LUCEE_EXTENSIONS}

# Map a host directory for web root with
#   -v <host-web-app-directory>:/srv/www/webapps/ROOT
ENV CATALINA_BASE /srv/www
ENV CATALINA_HOME /usr/local/tomcat
ENV LUCEE_DOWNLOAD http://release.lucee.org/rest/update/provider/loader/

# Lucee server directory
ENV LUCEE_SERVER ${CATALINA_BASE}/lucee-server

RUN cat /etc/os-release \
    && echo LUCEE_SERVER=${LUCEE_SERVER} \
    && echo Downloading Lucee ${LUCEE_VERSION}... \
    && $CATALINA_HOME/bin/makebase.sh $CATALINA_BASE \
    && curl -L -o "${CATALINA_BASE}/lib/${LUCEE_VERSION}.jar" "${LUCEE_DOWNLOAD}${LUCEE_VERSION}"

# copy the files from resources/catalina_base to the image
COPY resources/catalina-base ${CATALINA_BASE}

# copy custom Lucee server files, e.g. extensions from resources/lucee-server/deploy 
COPY resources/lucee-server ${LUCEE_SERVER}

# copy the files from app to the image
COPY app ${CATALINA_BASE}/webapps/ROOT

# create password.txt file if password is set
ARG LUCEE_ADMIN_PASSWORD=
ENV LUCEE_ADMIN_PASSWORD=${LUCEE_ADMIN_PASSWORD}

RUN if [ "$LUCEE_ADMIN_PASSWORD" != "" ] ; then \
        mkdir -p "${LUCEE_SERVER}/context" \ 
        && echo $LUCEE_ADMIN_PASSWORD > "${LUCEE_SERVER}/context/password.txt" ; \
    fi

# remove admin password from ENV
ENV LUCEE_ADMIN_PASSWORD=

RUN if [ "$LUCEE_VERSION" \> "5.3.6" ] ; then \
        echo "Enabled LUCEE_ENABLE_WARMUP" \
        && export LUCEE_ENABLE_WARMUP=true \
        && export LUCEE_EXTENSIONS \
        && catalina.sh run ; \
    else \
        echo "Start Tomcat and wait 20 seconds to shut down" \
        && catalina.sh start \
        && sleep 20 \
        && catalina.sh stop ; \
    fi

