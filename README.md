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

- TermIt: at least 512MB RAM (1GB and more is optimal), at least 2 CPUs
    - In case more users create and edit terms in TermIt, more CPUs is recommended
- TermIt UI: 100MB RAM
- GraphDB: at least 2GB RAM (depending on the amount of data stored), 1 CPU
- Annotace: at least 512MB RAM
- OntoGrapher: same as TermIt UI
- Keycloak + Postgres: (1CPU and approx. 512MB RAM)

Ideally, the whole deployment should have at least 4GB RAM available, with at least 2-3 CPU cores.

## Running TermIt

1. Set email server configuration in `.env`. In particular, set `MAIL_HOST`, `MAIL_USERNAME` and `MAIL_PASSWORD`, (
   optionally) `MAIL_PORT`.
2. (_Optional_) Set `ROOT` variable in `.env` to reflect the local context prefix the app will be running on.
3. (_Optional_) Set `HOST_PORT` variable in `.env` to reflect the port on which TermIt should be accessible.
4. (_Optional_) Set `URL` variable in `.env` to reflect the address TermIt will be running on. If the system is running
   behind a server proxy (like Apache), the URL should be the **public URL** provided by the server proxy (for
   example, https://termit.fel.cvut.cz). Otherwise,
   the URL should contain the `HOST_PORT` specified above (for example, http://localhost:1234). If the **public URL**
   is not based on standards HTTP(S) ports (80, 443), set also the `PUBLIC_PORT` so that the backend is able to
   correctly generate server URL for the API docs using Swagger UI.
5. (_Optional_) Set `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` in `.env` to a custom value.
6. Start all the services by running
   `docker-compose up -d`
7. (_Optional_) If you have a license for GraphDB, go to `${URL}/${ROOT}/sluzby/db-server/license/register` and upload
   the license file.
8. Go to `${URL}/${ROOT}/sluzby/db-server/import#server`, select the "termit" repository, and in the "Server files"
   section, click the "Import" button for all the files. In the "Import settings" dialog, set the Base IRI
   to `http://onto.fel.cvut.cz/ontologies/termit`.
9. Go to `${URL}/${ROOT}/sluzby/db-server/sparql` and execute all the queries in the `db-server/lucene` directory to
   create Lucene connectors for full-text search (see below w.r.t. the connector language settings).
10. (_Optional_, recommended) Go to Setup/Users and access and enable security. Create a new user that TermIt and other related services will use to access the `termit` repository. Give the new user write access to the `termit` repository. Set the new user's username and password as `GDB_USERNAME` a `GDB_PASSWORD` in `.env` so that all relevant applications can access the repository.
11. Go to `${URL}/${ROOT}/sluzby/auth` (http://localhost:1234/termit/sluzby/auth by default) and log into the Keycloak administration console using the `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` values. Switch to realm `termit` and register new users. Assign the new users roles (use one of `ROLE_ADMIN`, `ROLE_FULL_USER` or `ROLE_RESTRICTED_USER` for each user).
12. TermIt is now available at `${URL}/${ROOT}` (http://localhost:1234/termit by default), OntoGrapher at `${URL}/${ROOT}/ontographer` (http://localhost:1234/termit/ontographer by default).
    - Note that OntoGrapher requires that URI of the vocabulary/ies to be used is passed to it as query parameters in the URL. So the the URL would be, for example: http://localhost:1234/termit/ontographer/?vocabulary=http://onto.fel.cvut.cz/ontologies/termit

## Configuration

TermIt is highly configurable both in terms of the content and the way it runs. This section provides details on
the most important configuration options.

### Language

The default configuration assumes TermIt is run for Czech vocabularies. To use TermIt in other environments, the
following changes are needed:

#### TermIt

TermIt backend stores and loads strings based on the configured language. To change it, set
the `TERMIT_PERSISTENCE_LANGUAGE` value in `docker-compose.yml` to the appropriate language tag (e.g., en, de).

#### Full Text Search

Full text search (FTS) is implemented via Lucene connectors in the underlying GraphDB repository. These connectors are
language-specific, so to use a different language for TermIt and FTS working correctly, the Lucene connectors need to be
configured accordingly. To use a different language that Czech, set the following in the connector-creating SPARQL
queries in `db-server/lucene`:

- Set the value of the "languages" attribute to the appropriate language tag
- Set the value of the "analyzer" attribute to the appropriate fully qualified Lucene analyzer class name. See, for
  example, https://lucene.apache.org/core/4_0_0/analyzers-common/overview-summary.html.

### Further TermIt Configuration

As stated above, TermIt is highly configurable. The following table lists the names of environment variables that can be
passed to TermIt backend either directly in `docker-compose.yml`, in
an [env_file](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file), or via command line.

| Variable                                           | Explanation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|:---------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ```TERMIT_ADMIN_CREDENTIALSFILE```\*               | Name of the file in which admin credentials are saved when its account is generated.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ```TERMIT_ADMIN_CREDENTIALSLOCATION```\*           | Specifies the folder in which admin credentials are saved when its account is generated.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ```TERMIT_CHANGETRACKING_CONTEXT_EXTENSION```\*    | Extension appended to asset identifier (presumably a vocabulary ID) to denote its change tracking context<br>identifier.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ```TERMIT_COMMENTS_CONTEXT```\*                    | IRI of the repository context used to store comments (discussion to assets).<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ```TERMIT_CORS_ALLOWEDORIGINS```\*                 | A comma-separated list of allowed origins for CORS.<br>Default value: ```http://localhost:3000```<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ```TERMIT_TEMPLATE_EXCELIMPORT```                  | Template file for Excel import.<p><br>The purpose of configuring this file is mainly to have the value lists for term types and states in the<br>template aligned with the corresponding languages used by TermIt.<p><br>Empty value means the built-in template file should be used.                                                                                                                                                                                                                                                                                                                                                                                                      |
| ```TERMIT_FILE_STORAGE```\*                        | Specifies root directory in which document files are stored.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ```TERMIT_GLOSSARY_FRAGMENT```\*                   | IRI path to append to vocabulary IRI to get glossary identifier.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ```TERMIT_NAMESPACE_FILE_SEPARATOR```\*            | Separator of File namespace from the parent Document identifier.<p><br>Since File identifier is given by the identifier of the Document it belongs to and its own normalized label,<br>this separator is used to (optionally) configure the File identifier namespace.<p><br>For example, if we have a Document with IRI ```http://www.example.org/ontologies/resources/metropolitan-plan/document```<br>and a File with normalized label ```main-file```, the resulting IRI will be ```<br>http://www.example.org/ontologies/resources/metropolitan-plan/document/SEPARATOR/main-file```, where<br>'SEPARATOR' is the value of this configuration parameter.<br>value must be present     |
| ```TERMIT_NAMESPACE_RESOURCE```\*                  | Namespace for resource identifiers.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ```TERMIT_NAMESPACE_SNAPSHOT_SEPARATOR```\*        | Separator of snapshot timestamp and original asset identifier.<p><br>For example, if we have a Vocabulary with IRI ```http://www.example.org/ontologies/vocabularies/metropolitan-plan```<br>and the snapshot separator is configured to ```version```, a snapshot IRI will look something like ```http://www.example.org/ontologies/vocabularies/metropolitan-plan/version/20220530T202317Z```.<br>value must be present                                                                                                                                                                                                                                                                  |
| ```TERMIT_NAMESPACE_TERM_SEPARATOR```\*            | Separator of Term namespace from the parent Vocabulary identifier.<p><br>Since Term identifier is given by the identifier of the Vocabulary it belongs to and its own normalized<br>label, this separator is used to (optionally) configure the Term identifier namespace.<p><br>For example, if we have a Vocabulary with IRI ```http://www.example.org/ontologies/vocabularies/metropolitan-plan```<br>and a Term with normalized label ```inhabited-area```, the resulting IRI will be ```<br>http://www.example.org/ontologies/vocabularies/metropolitan-plan/SEPARATOR/inhabited-area```, where 'SEPARATOR'<br>is the value of this configuration parameter.<br>value must be present |
| ```TERMIT_NAMESPACE_USER```\*                      | Namespace for user identifiers.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ```TERMIT_NAMESPACE_VOCABULARY```\*                | Namespace for vocabulary identifiers.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ```TERMIT_PERSISTENCE_DRIVER```\*                  | OntoDriver class for the repository.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ```TERMIT_PERSISTENCE_LANGUAGE```\*                | Language used to store strings in the repository (persistence unit language).<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```TERMIT_PUBLICVIEW_WHITELISTPROPERTIES```\*      | Unmapped properties allowed to appear in the public term access API.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ```TERMIT_REPOSITORY_URL```\*                      | URL of the main application repository.<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ```TERMIT_TEXTANALYSIS_TERMOCCURRENCEMINSCORE```\* | Score threshold for a term occurrence for it to be saved into the repository.<br>Default value: ```0.49```<br>value must be present                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ```TERMIT_WORKSPACE_ALLVOCABULARIESEDITABLE```\*   | Whether all vocabularies in the repository are editable.<p><br>Allows running TermIt in two modes - one is that all vocabularies represent the current version and can be<br>edited. The other mode is that working copies of vocabularies are created and the user only selects a subset<br>of these working copies to edit (the so-called workspace), while all other vocabularies are read-only for<br>them.<br>Default value: ```true```<br>value must be present                                                                                                                                                                                                                      |
| ```TERMIT_MAIL_SENDER```                           | Human-readable name to use as email sender.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ```SPRING_MAIL_HOST```                             | Email server hostname.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```SPRING_MAIL_PORT```                             | Email server port.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ```SPRING_MAIL_USERNAME```                         | Email server username.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```SPRING_MAIL_PASSWORD```                         | Email server password.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```SPRING_SERVLET_MULTIPART_MAXFILESIZE```         | Maximum size of a single uploaded file                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```TERMIT_ACL_DEFAULTEDITORACCESSLEVEL```          | Default access level for users in the editor role.<br>Default value: ```READ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ```TERMIT_ACL_DEFAULTREADERACCESSLEVEL```          | Default access level for users in the reader role.<br>Default value: ```READ```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ```TERMIT_CORS_ALLOWEDORIGINPATTERNS```            | A comma-separated list of allowed origin patterns for CORS.<p><br>This allows a more dynamic configuration of allowed origins that ```\#allowedOrigins``` which contains exact<br>origin URLs. It is useful, for example, for Netlify preview builds of the frontend which use a generated<br>subdomain URL.                                                                                                                                                                                                                                                                                                                                                                               |
| ```TERMIT_JWT_SECRETKEY```                         | Secret key used when hashing a JWT.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ```TERMIT_LANGUAGE_STATES_SOURCE```                | Path to a file containing definition of the language of states terms can be in. The file must be in<br>Turtle format. The term definitions must use SKOS terminology for attributes (prefLabel, scopeNote and<br>broader/narrower).                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ```TERMIT_LANGUAGE_TYPES_SOURCE```                 | Path to a file containing definition of the language of types terms can be classified with.<p><br>The file must be in Turtle format. The term definitions must use SKOS terminology for attributes (prefLabel,<br>scopeNote and broader/narrower).                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ```TERMIT_MAIL_SENDER```                           | Human-readable name to use as email sender.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ```TERMIT_REPOSITORY_PASSWORD```                   | Password for connecting to the application repository.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```TERMIT_REPOSITORY_PUBLICURL```                  | Public URL of the main application repository.<p><br>Can be used to provide read-only no authorization access to the underlying data.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ```TERMIT_REPOSITORY_USERNAME```                   | Username for connecting to the application repository.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ```TERMIT_SCHEDULE_CRON_NOTIFICATION_COMMENTS```   | CRON expression configuring when to send notifications of changes in comments to admins and<br>vocabulary authors. Defaults to '-' which disables this functionality.<br>Default value: ```-```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ```TERMIT_SECURITY_PROVIDER```                     | Determines whether the internal security mechanism or an external OIDC service will be used for<br>authentication.<p><br>In case na OIDC service is selected, it should be configured using standard Spring Boot OAuth2 properties.<br>Default value: ```INTERNAL```                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ```TERMIT_SECURITY_ROLECLAIM```                    | Claim in the authentication token provided by the OIDC service containing roles mapped to TermIt user roles.<p><br>Supports nested objects via dot notation.<br>Default value: ```realm_access.roles```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ```TERMIT_TEXTANALYSIS_URL```                      | URL of the text analysis service.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ```TERMIT_URL```                                   | TermIt frontend URL.<p><br>It is used, for example, for links in emails sent to users.<br>Default value: ```http://localhost:3000/#```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
**\* Required**

### OntoGrapher

OntoGrapher is configured to use the same authentication service (Keycloak) as TermIt. It is also configured with adresses of other relevant services via the `ONTOGRAPHER_COMPONENTS` variable. If any changes are made to the paths/URLs of these services, it is necessary to update the `ONTOGRAPHER_COMPONENTS` value accordingly and rebuild the OntoGrapher image. The `ONTOGRAPHER_COMPONENTS` is a base 64-encoded JSON string, so it is necessary to decode it, make changes, and then encode it again.
### Host Proxy Configuration

TermIt uses Web sockets for asynchronous communication between the server and the clients. If the host system runs a web
proxy (most do),
this needs to be configured in the proxy.

#### Apache2

For the Apache HTTP server (default on Debian and other Linux systems) this can be done by enabling the
`mod_proxy_wstunnel` [module](https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html) and using the following
rewrite rule:

```apache2
# Proxy WebSocket connections to termit at port 1234
  RewriteCond %{HTTP:Upgrade} websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/termit?(.*) "ws://localhost:1234/termit/sluzby/server$1" [P,L]
```

#### Nginx

For nginx, this can be done by adding the following snippet, which initializes the `connection_upgrade` variable, to
the `http` section of the `nginx.conf` file:

```nginx
map $http_upgrade $connection_upgrade {
   default upgrade;
   ''      close;
}
```

```nginx
location /termit {
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection $connection_upgrade;
   # Other proxy headers and proxy_pass
}
```

### Keycloak

When using Keycloak as an authentication service behind a proxy, it is necessary to:
- Set `KC_HOSTNAME_URL` and `KC_HOSTNAME_ADMIN_URL` to the public URL at which Keycloak will be accessible to the outside world (proxied)
- Set `KC_HOSTNAME_STRICT_BACKCHANNEL` and `KC_PROXY` so that other services can use it via its Docker service URL
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUERURI` in TermIt (and db-server-proxy) to the **public URL** of TermIt. This URL is used to validate the authentication token
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI` in TermIt (and db-server-proxy) to the **Docker service URL** of Keycloak. This URL is used by TermIt to access the authentication service itself
- Both `TermIt UI` and `OntoGrapher` use the **public URL** of Keycloak
- Keycloak is configured to automatically import the pre-configured `termit` realm
And then adding the `Upgrade` and `Connection` headers to the request:
