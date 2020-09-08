# TermIt docker
TermIt docker serves to spin off a TermIt deployment, consisting of :
- GraphDB (database)
- TermIt (backend)
- TermIt UI (frontend)

## Prerequisities
First, You should have Docker installed (and accessible under current user).
Second, You need a valid GraphDB SE or EE license.

## Usage
Prior to building a Docker image, you should edit `docker-compose.yml`: 
- change GRAPHDB_LICENSE_FILE to point to your GraphDB SE or GraphDB EE license
- change backend.build.context and frontend.build.context to point to your local directories of 
TermIt (clone of `https://github.com/kbss-cvut/termit`) and TermIt UI (clone of `https://github.com/kbss-cvut/termit-ui`) 
respectively

To build docker images, execute `docker-compose build`
Then, to run the whole TermIt platform, execute `docker-compose up` 