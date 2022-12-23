FROM eclipse-temurin:11-jdk-alpine

# Add curl
RUN apk --no-cache add curl

ARG GRAPHDB_ZIP

RUN \
    # Check for mandatory build arguments
    : "${GRAPHDB_ZIP:?Provide the downloaded GraphDB Free ZIP file}"

ENV GRAPHDB_VOLUME=/graphdb
ENV GRAPHDB_HOME=${GRAPHDB_VOLUME}/home
ENV GRAPHDB_INSTALL_DIR=${GRAPHDB_VOLUME}/dist
RUN mkdir -p $GRAPHDB_VOLUME $GRAPHDB_INSTALL_DIR $GRAPHDB_HOME

ADD $GRAPHDB_ZIP /tmp/$GRAPHDB_ZIP

WORKDIR /tmp
RUN unzip $GRAPHDB_ZIP
RUN export GRAPHDB_DIR=`ls -d graphdb*/` && mv $GRAPHDB_DIR/* $GRAPHDB_INSTALL_DIR

ENV PATH=${GRAPHDB_INSTALL_DIR}/bin:$PATH

COPY rulesets ${GRAPHDB_HOME}/rulesets

COPY init-data /root/graphdb-import
COPY init-config /termit-repo-config
COPY repo-init.sh ${GRAPHDB_INSTALL_DIR}/repo-init.sh

COPY conf ${GRAPHDB_HOME}/conf

CMD ["-Dgraphdb.home=/graphdb/home","-Dgraphdb.logback=conf/logback.xml"]
ENTRYPOINT ["/graphdb/dist/bin/graphdb"]
EXPOSE 7200
