FROM ontotext/graphdb:10.8.8

# Override parent entrypoint
ENTRYPOINT []

ENV GRAPHDB_HOME=/opt/graphdb/home
ENV GRAPHDB_INSTALL_DIR=/opt/graphdb/dist

WORKDIR ${GRAPHDB_HOME}

# Copy our custom ruleset
COPY rulesets rulesets

# Copy initialization data and repository config
COPY init-data /termit-init-data
COPY init-config /termit-repo-config
COPY repo-init.sh ${GRAPHDB_INSTALL_DIR}/repo-init.sh

EXPOSE 7200

# Health check asking for termit repository
# When security is enabled, it wont be able to ensure repository existence and will accept 401 as success
HEALTHCHECK --start-period=15s \
    CMD curl -s -o /dev/null -w '%{http_code}' --max-time 5 \
        http://localhost:7200/rest/monitor/repository/termit \
        | grep -qE '^(200|401)$' || exit 1

CMD ${GRAPHDB_INSTALL_DIR}/repo-init.sh /termit-repo-config /termit-init-data ${GRAPHDB_HOME} & ${GRAPHDB_INSTALL_DIR}/bin/graphdb -Dgraphdb.home=${GRAPHDB_HOME} -Dgraphdb.logback=${GRAPHDB_INSTALL_DIR}/conf/logback.xml

