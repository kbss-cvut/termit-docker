# TermIt Docker
TermIt Docker serves to spin off a TermIt deployment, consisting of:

- [GraphDB](https://www.ontotext.com/products/graphdb/) (database)
- [TermIt](https://github.com/kbss-cvut/termit) (backend)
- [Annotace](https://github.com/kbss-cvut/annotace)
- [TermIt UI](https://github.com/kbss-cvut/termit-ui) (frontend)
- [OntoGrapher](https://github.com/datagov-cz/ontoGrapher/tree/standalone) (standalone branch)
- [Keycloak](https://www.keycloak.org/)

## Prerequisities
- Docker 23.0.1 or later & Docker Compose installed (and accessible under the current user).

### Resource Requirements

- TermIt: at least 512MB RAM (1GB and more is optimal), 1 CPU
- TermIt UI: 100MB RAM is more than enough
- GraphDB: at least 2GB RAM (depending on the amount of data stored), 1 CPU
- Annotace: at least 512MB RAM
- OntoGrapher: same as TermIt UI
- Keycloak + Postgres: (1CPU and approx. 512MB RAM)

Ideally, the whole deployment should have at least 4GB RAM available, with at least 2-3 CPU cores.


## Running TermIt
1. (_Optional_) Set `ROOT` variable in `.env` to reflect the local context prefix the app will be running on.
2. (_Optional_) Set `URL` variable in `.env` to reflect the server the app will be running on.
3. (_Optional_) Set `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` in `.env` to a custom value.
3. Start the GraphDB server
   `docker-compose up -d termit-db-server`
4. (_Optional_) If you have a license for GraphDB, go to http://localhost:7200/license/register and upload the license file.
5. Go to http://localhost:7200/import#server, select the "termit" repository, and in the "Server files" section, click the "Import" button for all the files. In the "Import settings" dialog, set the Base IRI and Target graph to `http://onto.fel.cvut.cz/ontologies/termit`.
6. Go to http://localhost:7200/sparql and execute all the queries in the `db-server/lucene` directory to create Lucene connectors for full-text search.
7. (_Optional_, recommended) Go to Setup/Users and access and enable security. Create a new user that TermIt and other related services will use to access the `termit` repository. Give the new user write access to the `termit` repository. Set the new user's username and password as `GDB_USERNAME` a `GDB_PASSWORD` in `.env` so that all relevant applications can access the repository.
8. Run the remaining services by
    `docker-compose up -d`
9. Go to `${URL}/${ROOT}/sluzby/auth` (http://localhost/termit/sluzby/auth by default) and log into the Keycloak administration console using the `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` values. Switch to realm `termit` and register new users. Assign the new users roles (use one of `ROLE_ADMIN`, `ROLE_FULL_USER` or `ROLE_RESTRICTED_USER` for each user).
10. TermIt is now available at `${URL}/${ROOT}` (http://localhost/termit by default), OntoGrapher at `${URL}/${ROOT}/ontographer` (http://localhost/termit/ontographer by default).
    - Note that OntoGrapher requires that URI of the vocabulary/ies to be used is passed to it as query parameters in the URL. So the the URL would be, for example: http://localhost/termit/ontographer/?vocabulary=http://onto.fel.cvut.cz/ontologies/termit

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

### OntoGrapher

OntoGrapher is configured to use the same authentication service (Keycloak) as TermIt. It is also configured with adresses of other relevant services via the `ONTOGRAPHER_COMPONENTS` variable. If any changes are made to the paths/URLs of these services, it is necessary to update the `ONTOGRAPHER_COMPONENTS` value accordingly and rebuild the OntoGrapher image. The `ONTOGRAPHER_COMPONENTS` is a base 64-encoded JSON string, so it is necessary to decode it, make changes, and then encode it again.

### Keycloak

When using Keycloak as an authentication service behind a proxy, it is necessary to:
- Set `KC_HOSTNAME_URL` and `KC_HOSTNAME_ADMIN_URL` to the public URL at which Keycloak will be accessible to the outside world (proxied)
- Set `KC_HOSTNAME_STRICT_BACKCHANNEL` and `KC_PROXY` so that other services can use it via its Docker service URL
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUERURI` in TermIt (and db-server-proxy) to the **public URL** of TermIt. This URL is used to validate the authentication token
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI` in TermIt (and db-server-proxy) to the **Docker service URL** of Keycloak. This URL is used by TermIt to access the authentication service itself
- Both `TermIt UI` and `OntoGrapher` use the **public URL** of Keycloak
- Keycloak is configured to automatically import the pre-configured `termit` realm
