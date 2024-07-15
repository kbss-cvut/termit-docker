FROM ontotext/graphdb:10.7.0

# Override parent entrypoint
ENTRYPOINT []

ENV GRAPHDB_HOME=/opt/graphdb/home
ENV GRAPHDB_INSTALL_DIR=/opt/graphdb/dist

WORKDIR ${GRAPHDB_HOME}

# Copy our custom ruleset
COPY rulesets rulesets

# Copy initialization data and repository config
COPY init-data /root/graphdb-import
COPY init-config /termit-repo-config
COPY repo-init.sh ${GRAPHDB_INSTALL_DIR}/repo-init.sh

EXPOSE 7200

CMD ${GRAPHDB_INSTALL_DIR}/repo-init.sh /termit-repo-config ${GRAPHDB_HOME} & ${GRAPHDB_INSTALL_DIR}/bin/graphdb -Dgraphdb.home=${GRAPHDB_HOME} -Dgraphdb.logback=${GRAPHDB_INSTALL_DIR}/conf/logback.xml

