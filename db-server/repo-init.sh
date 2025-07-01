#!/bin/sh

#
# Initializes TermIt GraphDB repository if it does not already exist
#

SOURCE_DIR=$1
INIT_DATA_DIR=$2
GRAPHDB_HOME=$3
REPO_NAME=termit

echo "Running repository initializer..."

if [ ! -d ${GRAPHDB_HOME}/data/repositories/${REPO_NAME} ] || [ -z "$(ls -A ${GRAPHDB_HOME})/data/repositories/${REPO_NAME}" ]; then
	echo "Initializing TermIt repository..."
    # Wait for GraphDB to start up
    echo "Waiting for GraphDB to start up..."
    sleep 15s

    # Create repository based on configuration
    echo "Creating TermIt repository..."
    curl -X POST -H "Content-Type: multipart/form-data" -F "config=@${SOURCE_DIR}/config.ttl" "http://localhost:7200/rest/repositories"
    echo "TermIt repository successfully initialized."

    echo "Uploading default ontologies..."
    for file in ${INIT_DATA_DIR}/*; do
      echo "Uploading ${file}..."
      curl -X POST -H "Content-Type: application/trig" -T "${file}" "http://localhost:7200/repositories/${REPO_NAME}/statements"
    done
    echo "Default ontologies successfully uploaded."
else
    echo "TermIt repository already exists. Skipping initialization..."
fi

