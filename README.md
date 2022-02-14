# TermIt docker
TermIt docker serves to spin off a TermIt deployment, consisting of :
- GraphDB (database)
- TermIt (backend)
- Annotace (backend)
- TermIt UI (frontend)

## Prerequisities
First, You should have Docker & Docker Compose installed (and accessible under current user).
Third, You need to have docker images of [termit](https://github.com/kbss-cvut/termit-ui) and [termit-server](https://github.com/kbss-cvut/termit) built.

## Running TermIt
1. Download [GraphDB](https://www.ontotext.com) (Free, SE, EE) standalone server ZIP archive and place it into the 'db-server' folder. TermIt can be successfully run with GraphDB Free 9.10.1, but other versions should be usable as well.
2. Set `GRAPHDB_FILE` variable in `.env` to the name of the file You just downloaded.
3. Clone [Annotace](https://github.com/kbss-cvut/annotace) (`termit` branch) as a new subfolder `annotace-server`, i.e.
   
   `git clone https://github.com/kbss-cvut/annotace annotace-server --branch termit`

Alternatively, a prebuilt Docker image for Annotace is available. In order to use it and avoid cloning Annotace, remove the `services.annotace-server.build` section and set `services.annotace-server.image` to `ghcr.io/kbss-cvut/annotace/annotace-spark:latest` in `docker-compose.yml`. Similarly, if you have previously built images for `termit-server` (step 4 below) and `termit-ui` (step 5 below), you can use them in a similar way.
4. Clone [TermIt server](https://github.com/kbss-cvut/termit) as a new subfolder `termit-server`, i.e.
   
   `git clone https://github.com/kbss-cvut/termit termit-server`
5. Clone [TermIt UI](https://github.com/kbss-cvut/termit-ui) as a new subfolder `termit`, i.e.
   
   `git clone https://github.com/kbss-cvut/termit-ui termit`
   
6. Set `ROOT` variable in .env to reflect the local context prefix the app will be running on.
7. Set `URL` variable in .env to reflect the server the app will be running on.
8. Start the GraphDB server
   `docker-compose up -d termit-db-server`
9. Go to `http://localhost:7200/import#server` and upload all the "Server files" into the context `http://onto.fel.cvut.cz/ontologies/termit`
   in the `termit` repository.
10. Go to `http://localhost:7200/sparql` and execute all the queries in the `db-server/lucene` directory to create lucene connectors for full-text search.
11. Run the remaining services by
    `docker-compose up -d`
12. Look for the admin password to the `termit-server` log and use it for first login at the configured URL, e.g. `http://localhost/termit`.
