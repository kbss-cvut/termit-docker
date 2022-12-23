#!/bin/sh

#
# Initializes TermIt GraphDB repository if it does not already exist
#

SOURCE_DIR=$1
GRAPHDB_HOME=$2
REPO_NAME=termit

echo "Running repository initializer..."

if [ ! -d ${GRAPHDB_HOME}/data/repositories/${REPO_NAME} ] || [ -z "$(ls -A ${GRAPHDB_HOME})/data/repositories/${REPO_NAME}" ]; then
	echo "Initializing TermIt repository..."
    # Wait for GraphDB to start up
    echo "Waiting for GraphDB to start up"
    sleep 15s

    # Create repository based on configuration
    curl -X POST --header "Content-Type: multipart/form-data" -F "config=@${SOURCE_DIR}/config.ttl" "http://localhost:7200/rest/repositories"
    curl -X POST --data-urlencode "update@${SOURCE_DIR}/create-label-index.rq" "http://localhost:7200/repositories/${REPO_NAME}/statements"
    curl -X POST --data-urlencode "update@${SOURCE_DIR}/create-defcom-index.rq" "http://localhost:7200/repositories/${REPO_NAME}/statements"
else
    echo "TermIt repository already exists. Skipping initialization..."
fi

