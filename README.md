# TermIt Docker

TermIt is a [SKOS](https://www.w3.org/TR/skos-reference/) compliant terminology management tool based on Semantic Web
technologies. It allows managing vocabularies consisting of thesauri and ontologies. It can also manage documents whose
content can be used to seed the vocabularies (e.g., normative documents with definition of domain terminology). In
addition, documents can also be analyzed to discover occurrences of the vocabulary terms.

TermIt Docker serves to spin off a TermIt deployment using Docker Compose. The deployment consists of:

- [GraphDB](https://www.ontotext.com/products/graphdb/) (database)
- [TermIt](https://github.com/kbss-cvut/termit) (backend)
- [Annotace](https://github.com/kbss-cvut/annotace)
- [Validation service](https://github.com/kbss-cvut/validation-service/)
- [TermIt UI](https://github.com/kbss-cvut/termit-ui) (frontend)
- [OntoGrapher](https://github.com/datagov-cz/ontoGrapher/tree/standalone) (standalone branch)
- [Keycloak](https://www.keycloak.org/)

## Prerequisites

- Docker 23.0.1 or later & Docker Compose installed (and accessible under the current user).

### Resource Requirements

- TermIt: at least 512MB RAM (1GB and more is optimal), at least 2 CPUs
    - In case more users create and edit terms in TermIt, more CPUs are recommended
- TermIt UI: 100MB RAM
- GraphDB: at least 2GB RAM (depending on the amount of data stored), 1 CPU
- Annotace: at least 512MB RAM
- Validation service: at least 1GB RAM (depending on the size of the vocabulary)
- OntoGrapher: same as TermIt UI
- Keycloak + Postgres: (1CPU and approx. 512MB RAM)

Ideally, the whole deployment should have at least 4GB RAM available, with at least 2–3 CPU cores.

## Running TermIt

1. Set email server configuration in `.env`. In particular, set `MAIL_HOST`, `MAIL_USERNAME` and `MAIL_PASSWORD`,
   (optionally) `MAIL_PORT`.
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
8. Go to `${URL}/${ROOT}/sluzby/db-server/sparql` and execute all the queries in the `db-server/lucene` directory to
   create Lucene connectors for full-text search (see below w.r.t. the connector language settings).
10. (_Optional_, recommended) Go to Setup/Users and access and enable security. Create a new user that TermIt and other
    related services will use to access the `termit` repository. Give the new user write access to the `termit`
    repository. Set the new user's username and password as `GDB_USERNAME` a `GDB_PASSWORD` in `.env` so that all
    relevant applications can access the repository.
11. Go to `${URL}/${ROOT}/sluzby/auth` (http://localhost:1234/termit/sluzby/auth by default) and log into the Keycloak
    administration console using the `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` values. Switch to realm
    `termit` and register new users. Assign the new users roles (use one of `ROLE_ADMIN`, `ROLE_FULL_USER` or
    `ROLE_RESTRICTED_USER` for each user).
12. TermIt is now available at `${URL}/${ROOT}` (http://localhost:1234/termit by default), OntoGrapher at
    `${URL}/${ROOT}/ontographer` (http://localhost:1234/termit/ontographer by default).
    - Note that OntoGrapher requires that URI of the vocabulary/ies to be used is passed to it as query parameters in
      the URL. So the URL would be, for
      example: http://localhost:1234/termit/ontographer/?vocabulary=http://onto.fel.cvut.cz/ontologies/termit

### Which Docker Compose File to Use

## Configuration

TermIt is highly configurable both in terms of the content and the way it runs. This section provides details on
the most important configuration options.

### Language

TermIt backend uses a default language to set the primary language for vocabularies if not specified by the user.
By default, Czech is used. To configure it, set the `TERMIT_PERSISTENCE_LANGUAGE` value in `docker-compose.yml` to the
appropriate language tag (e.g., en, de).

Similarly, all identifier generators use Czech namespaces. If this is a problem for you, you can change them (see the
next paragraph).

### Further Backend Configuration

[This table](./termit-config.md) lists the names of environment
variables that can be passed to TermIt backend either directly in `docker-compose.yml`, in
an [env_file](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file) (`.env` is already configured), or
via command line.

The parameters are based on
the [Configuration](https://github.com/kbss-cvut/termit/blob/master/src/main/java/cz/cvut/kbss/termit/util/Configuration.java)
class in TermIt backend. If you need to further adjust the behavior of TermIt, consult this class.

### Host Proxy Configuration

TermIt uses Web sockets for asynchronous communication between the server and the clients. If the host system runs a web
proxy (most do), this needs to be configured in the proxy.

#### Apache2

For the Apache HTTP Server (default on Debian and other Linux systems) this can be done by enabling the
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

And then adding the `Upgrade` and `Connection` headers to the request:

```nginx
location /termit {
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection $connection_upgrade;
   # Other proxy headers and proxy_pass
}
```

### Keycloak

When using Keycloak as an authentication service behind a proxy, it is necessary to:

- Set `KC_HOSTNAME_URL` and `KC_HOSTNAME_ADMIN_URL` to the public URL at which Keycloak will be accessible to the
  outside world (proxied)
- Set `KC_HOSTNAME_STRICT_BACKCHANNEL` and `KC_PROXY` so that other services can use it via its Docker service URL
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUERURI` in TermIt (and db-server-proxy) to the **public URL** of
  TermIt. This URL is used to validate the authentication token
- Set `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI` in TermIt (and db-server-proxy) to the **Docker service URL
  ** of Keycloak. This URL is used by TermIt to access the authentication service itself
- Both `TermIt UI` and `OntoGrapher` use the **public URL** of Keycloak
- Keycloak is configured to automatically import the pre-configured `termit` realm
  And then adding the `Upgrade` and `Connection` headers to the request:

### Monitoring

TermIt backend publishes metrics for [Prometheus](https://prometheus.io/) using Spring Boot Actuator.
[Grafana](https://grafana.com/) and Prometheus can be used to monitor TermIt based on these metrics.
`docker-compose.yml`
provides a basic setup for monitoring TermIt using these tools. In order to use it, set the following environment
variables:

- `GRAFANA_USERNAME` - Grafana admin user
- `GRAFANA_PASSWORD` - Grafana admin user password
- `ACTUATOR_USERNAME` - used to secure access to the Actuator metrics endpoint
- `ACTUATOR_PASSWORD` - used to secure access to the Actuator metrics endpoint

Start the whole system (including the monitoring services) by running
`docker-compose up -d`
and go to `${URL}/${ROOT}/sluzby/monitoring` to access the Grafana dashboard. Login using the `GRAFANA_USERNAME` and
`GRAFANA_PASSWORD` environment variables.

A basic dashboard (called `TermIt State`) is provided (see `monitoring/grafana/provisioning`). Feel free to adjust it as
necessary.

_Note that if you do not set the actuator credentials, TermIt will generate random credentials for you, but this will
mean Prometheus (and thus Grafana) will not be able to access the metrics endpoint._