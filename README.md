# TermIt Docker
TermIt Docker serves to spin off a TermIt deployment, consisting of:

- [GraphDB](https://www.ontotext.com/products/graphdb/) (database)
- [TermIt](https://github.com/kbss-cvut/termit) (backend)
- [Annotace](https://github.com/kbss-cvut/annotace)
- [TermIt UI](https://github.com/kbss-cvut/termit-ui) (frontend)

## Prerequisities
- Docker 19.03.0 or later & Docker Compose installed (and accessible under the current user).

### Resource Requirements

- TermIt: at least 512MB RAM (1GB and more is optimal), 1 CPU
- TermIt UI: 100MB RAM is more than enough
- GraphDB: at least 2GB RAM (depending on the amount of data stored), 1 CPU
- Annotace: at least 512MB RAM

Ideally, the whole deployment should have at least 4GB RAM available, with at least 2-3 CPU cores.


## Running TermIt
1. (_Optional_) If you have a license file for GraphDB (SE or EE), place it in the `db-server/license` directory.
2. (_Optional_) Set `ROOT` variable in `.env` to reflect the local context prefix the app will be running on.
3. (_Optional_) Set `URL` variable in `.env` to reflect the server the app will be running on.
4. (_Optional_, recommended) Set `JWT_SECRET_KEY` variable in `.env`. It should be a string of at least 32 characters that will be used to hash the JWT authentication token for logged-in users.
5. Start the GraphDB server
   `docker-compose up -d termit-db-server`
6. Go to http://localhost:7200/import#server, select the "termit" repository, and in the "Server files" section, click the "Import" button for all the files. In the "Import settings" dialog, set the Base IRI to `http://onto.fel.cvut.cz/ontologies/termit`.
7. Go to http://localhost:7200/sparql and execute all the queries in the `db-server/lucene` directory to create Lucene connectors for full-text search.
8. Run the remaining services by
    `docker-compose up -d`
9. Look for admin credentials in the `termit-server` log (on Linux/WSL, you can use grep: `docker-compose logs | grep "Admin credentials"`) and use them for first login at the configured URL, e.g. http://localhost/termit.

## Configuration

TermIt is highly configurable both in terms of the content as well as the way it runs. This section provides details on the most important configuration options.

### Language

The default configuration assumes TermIt is run for Czech vocabularies. To use TermIt in other environments, the following changes are needed:

#### TermIt

TermIt backend stores and loads strings based on the configured language. To change it, set the `TERMIT_PERSISTENCE_LANGUAGE` value in `docker-compose.yml` to the appropriate language tag (e.g., en, de).

#### Full Text Search

Full text search (FTS) is implemented via Lucene connectors in the underlying GraphDB repository. These connectors are language-specific, so to use a different language for TermIt and FTS working correctly, the Lucene connectors need to be configured accordingly. To use a different language that Czech, set the following in the connector-creating SPARQL queries in `db-server/lucene`:

- Set the value of the "languages" attribute to the appropriate language tag
- Set the value of the "analyzer" attribute to the appropriate fully qualified Lucene analyzer class name. See, for example, https://lucene.apache.org/core/4_0_0/analyzers-common/overview-summary.html.

### Further TermIt Configuration

As stated above, TermIt is highly configurable. The following table lists the names of environment variables that can be passed to TermIt backend either directly in `docker-compose.yml`, in an [env_file](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file), or via command line.

| Variable | Explanation |
| :------- | :---------- |
| `TERMIT_URL` | TermIt frontend URL. Used, for example, for links in emails sent to users. |
| `TERMIT_PERSISTENCE_LANGUAGE` | Primary language used to store strings in the repository (persistence unit language). |
| `TERMIT_CHANGETRACKING_CONTEXT_EXTENSION` | Extension appended to asset identifier (presumably a vocabulary ID) to denote its change tracking context identifier. |
| `TERMIT_COMMENTS_CONTEXT` | IRI of the repository context used to store comments. |
| `TERMIT_NAMESPACE_VOCABULARY` | Namespace for vocabulary identifiers. |
| `TERMIT_NAMESPACE_USER` | Namespace for user identifiers. |
| `TERMIT_NAMESPACE_RESOURCE` | Namespace for resource identifiers |
| `TERMIT_NAMESPACE_TERM_SEPARATOR` | Separator of Term namespace from the parent Vocabulary identifier. Since Term identifier is given by the identifier of the Vocabulary it belongs to and its own normalized label, this separator is used to (optionally) configure the Term identifier namespace. For example, if we have a Vocabulary with IRI `http://www.example.org/ontologies/vocabularies/metropolitan-plan` and a Term with normalized label `inhabited-area`, the resulting IRI will be `http://www.example.org/ontologies/vocabularies/metropolitan-plan/SEPARATOR/inhabited-area`, where 'SEPARATOR' is the value of this configuration parameter. |
| `TERMIT_NAMESPACE_FILE_SEPARATOR` | Separator of File namespace from the parent Document identifier. See above for explanation. |
| `TERMIT_NAMESPACE_SNAPSHOT_SEPARATOR` | Separator of snapshot timestamp and original asset identifier. For example, if we have a Vocabulary with IRI `http://www.example.org/ontologies/vocabularies/metropolitan-plan` and the snapshot separator is configured to `version`, a snapshot will IRI will look something like `http://www.example.org/ontologies/vocabularies/metropolitan-plan/version/20220530T202317Z`. |
| `TERMIT_ADMIN_CREDENTIALSLOCATION` | Specifies the folder in which admin credentials are saved when its account is generated. |
| `TERMIT_ADMIN_CREDENTIALSFILE` | Name of the file in which admin credentials are saved when its account is generated. |
| `TERMIT_TEXTANALYSIS_TERMOCCURRENCEMINSCORE` | Score threshold for a term occurrence for it to be saved into the repository. |
| `TERMIT_GLOSSARY_FRAGMENT` | IRI path to append to vocabulary IRI to get glossary identifier. |
| `TERMIT_PUBLICVIEW_WHITELISTPROPERTIES` |  A comma-separated set of unmapped properties allowed to appear in the base SKOS export. |
| `TERMIT_WORKSPACE_ALLVOCABULARIESEDITABLE` | Whether all vocabularies in the repository are editable. Allows running TermIt in two modes - one is that all vocabularies represent the current version and can be edited. The other mode is that working copies of vocabularies are created and the user only selects a subset of these working copies to edit (the so-called workspace), while all other vocabularies are read-only for them. |
| `TERMIT_SCHEDULE_CRON_NOTIFICATION_COMMENTS` |  CRON expression configuring when to send notifications of changes in comments to admins and vocabulary authors. Defaults to `-` which disables this functionality. |
| `TERMIT_MAIL_SENDER` | Human-readable name to use as email sender. |
| `SPRING_MAIL_HOST` | Email server hostname. |
| `SPRING_MAIL_PORT` | Email server port. |
| `SPRING_MAIL_USERNAME` | Email server username. |
| `SPRING_MAIL_PASSWORD` | Email server password. |

The parameters are based on the [Configuration](https://github.com/kbss-cvut/termit/blob/master/src/main/java/cz/cvut/kbss/termit/util/Configuration.java) class in TermIt backend. If you need to further adjust the behavior of TermIt, consult this class.


