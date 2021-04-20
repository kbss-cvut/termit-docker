FROM ontotext/graphdb:8.10.1-se as graphdb
ARG GRAPHDB_LICENSE_FILE
WORKDIR /opt/graphdb/home
RUN rm -rf data
COPY $GRAPHDB_LICENSE_FILE /opt/graphdb/home/conf/
COPY data data
EXPOSE 7200