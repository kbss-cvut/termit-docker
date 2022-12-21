# TermIt docker
TermIt docker serves to spin off a TermIt deployment, consisting of :
- GraphDB (database)
- TermIt (backend)
- Annotace (backend)
- TermIt UI (frontend)

## Prerequisities
1. You should have Docker & Docker Compose installed (and accessible under current user).
2. You need to have [GraphDB](https://www.ontotext.com) (Free, SE, EE) ZIP file downloaded. Note that TermIt requires GraphDB *8.x* or *9.x*, it will **not** work with GraphDB *10.x*.


## Running TermIt
1. Place your [GraphDB](https://www.ontotext.com) (Free, SE, EE) standalone server ZIP archive into the 'db-server' folder.
2. Set `GRAPHDB_FILE` variable in `.env` to the name of the file you just downloaded. 
3. Set `ROOT` variable in .env to reflect the local context prefix the app will be running on.
4. Set `URL` variable in .env to reflect the server the app will be running on.
5. (Optional, recommended) Set `JWT_SECRET_KEY` variable in .env. It should be a string of at least 32 characters that will be used to hash the JWT authentication token for logged-in users.
6. Start the GraphDB server
   `docker-compose up -d termit-db-server`
7. Go to `http://localhost:7200/import#server`, select the "termit" repository, and in the "Server files" section, click the "Import" button for all the files. In the "Import settings" dialog, set the Base IRI to `http://onto.fel.cvut.cz/ontologies/termit`.
8. Go to `http://localhost:7200/sparql` and execute all the queries in the `db-server/lucene` directory to create lucene connectors for full-text search.
9. Run the remaining services by
    `docker-compose up -d`
10. Look for the admin password to the `termit-server` log and use it for first login at the configured URL, e.g. `http://localhost/termit`.

