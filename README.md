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

## Prerequisites

- Docker 19.03.0 or later & Docker Compose installed (and accessible under the current user).

### Resource Requirements

- TermIt: at least 512MB RAM (1GB and more is optimal), at least 2 CPUs
    - In case more users create and edit terms in TermIt, more CPUs are recommended
- TermIt UI: 100MB RAM
- GraphDB: at least 2GB RAM (depending on the amount of data stored), 1 CPU
- Annotace: at least 512MB RAM
- Validation service: at least 1GB RAM (depending on the size of the vocabulary)

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
5. (_Optional_, recommended) Set `JWT_SECRET_KEY` variable in `.env`. It should be a string of at least 32 characters
   that will be used to hash the JWT authentication token for logged-in users.
6. Start all the services by running
   `docker-compose up -d`
7. (_Optional_) If you have a license for GraphDB, go to `${URL}/${ROOT}/sluzby/db-server/license/register` and upload
   the license file.
8. Look for admin credentials in the `termit-server` log (on Linux/WSL, you can use
   grep: `docker-compose logs | grep "Admin credentials"`) and use them for first login at the configured URL,
   e.g., http://localhost:1234/termit.

### Security Note

Note that the default setup shown above does not protect access to the GraphDB repository. If TermIt as a whole is
exposed (e.g., via a reverse proxy), anyone could access and edit data in GraphDB. To fix this, go to the GraphDB
workbench (at `${URL}/${ROOT}/sluzby/db-server`), go to "Setup" -> "Users and Access", create an admin user and enable
security. Then create another user for TermIt and give it write access to the `termit` repository. Use the TermIt user's
credentials as values for `GDB_USERNAME` and `GDB_PASSWORD` in `.env` and restart all services.

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
