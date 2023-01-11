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
    echo "Waiting for GraphDB to start up..."
    sleep 15s

    # Create repository based on configuration
    echo "Creating TermIt repository..."
    curl -X POST --header "Content-Type: multipart/form-data" -F "config=@${SOURCE_DIR}/config.ttl" "http://localhost:7200/rest/repositories"
    echo "TermIt repository successfully initialized."
else
    echo "TermIt repository already exists. Skipping initialization..."
fi

