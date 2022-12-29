# TermIt Docker
TermIt Docker serves to spin off a TermIt deployment, consisting of:

- [GraphDB](https://www.ontotext.com/products/graphdb/) (database)
- [TermIt](https://github.com/kbss-cvut/termit) (backend)
- [Annotace](https://github.com/kbss-cvut/annotace) (backend)
- [TermIt UI](https://github.com/kbss-cvut/termit-ui) (frontend)

## Prerequisities
1. You should have Docker & Docker Compose installed (and accessible under current user).
2. You need to have [GraphDB](https://www.ontotext.com) (Free, SE, EE) ZIP file downloaded. Note that TermIt requires GraphDB *8.x* or *9.x*, it currently does **not** work with GraphDB *10.x*.


## Running TermIt
1. Place your [GraphDB](https://www.ontotext.com) (Free, SE, EE) standalone server ZIP archive into the 'db-server' folder.
2. Set `GRAPHDB_FILE` variable in `.env` to the name of the file you just downloaded. 
3. Set `ROOT` variable in .env to reflect the local context prefix the app will be running on.
4. Set `URL` variable in .env to reflect the server the app will be running on.
5. (Optional, recommended) Set `JWT_SECRET_KEY` variable in .env. It should be a string of at least 32 characters that will be used to hash the JWT authentication token for logged-in users.
6. Start the GraphDB server
   `docker-compose up -d termit-db-server`
7. Go to `http://localhost:7200/import#server`, select the "termit" repository, and in the "Server files" section, click the "Import" button for all the files. In the "Import settings" dialog, set the Base IRI to `http://onto.fel.cvut.cz/ontologies/termit`.
8. Go to `http://localhost:7200/sparql` and execute all the queries in the 'db-server/lucene' directory to create Lucene connectors for full-text search.
9. Run the remaining services by
    `docker-compose up -d`
10. Look for the admin password to the `termit-server` log and use it for first login at the configured URL, e.g. `http://localhost/termit`.

## Configuration

TermIt is highly configurable both in terms of the content as well as the way it runs. This section provides details on the most important configuration options.

### Language

The default configuration assumes TermIt is run for Czech vocabularies. To use TermIt in other environments, the following changes are needed:

#### TermIt

TermIt backend stores and loads strings based on the configured language. To change it, set the `TERMIT_PERSISTENCE_LANGUAGE` value in 'docker-compose.yml' to the appropriate language tag (e.g., en, de).

#### Full Text Search

Full text search (FTS) is implemented via Lucene connectors in the underlying GraphDB repository. These connectors are language-specific, so to use a different language for TermIt and FTS working correctly, the Lucene connectors need to be configured accordingly. To use a different language that Czech, set the following in the connector-creating SPARQL queries in 'db-server/lucene':

- Set the value of the "languages" attribute to the appropriate language tag
- Set the value of the "analyzer" attribute to the appropriate fully qualified Lucene analyzer class name. See, for example, https://lucene.apache.org/core/4_0_0/analyzers-common/overview-summary.html.

