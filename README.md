# TermIt docker
TermIt docker serves to spin off a TermIt deployment, consisting of :
- GraphDB (database)
- TermIt (backend)
- TermIt UI (frontend)

## Prerequisities
First, You should have Docker & Docker Compose installed (and accessible under current user).
Second, You need a valid GraphDB Free installation package (or a valid SE or EE license).
Third, You need to have docker images of [termit](https://github.com/kbss-cvut/termit-ui) and [termit-server](https://github.com/kbss-cvut/termit) built.

Edit `docker-compose.yml`:
- download GraphDB Free ZIP and place it into the `graphdb` folder.
- set `services.termit-db-server.build.args.GRAPHDB_ZIP` to the respective GraphDB distribution file, e.g. `graphdb-free-9.6.0-dist.zip`
- set `services.termit.image` to the respective docker image of TermIt frontend
- set `services.termit-server.image` to the respective docker image of TermIt backend
- adjust `ROOT` in .env to reflect the local context prefix the app will be running on. WARNING: TermIt frontend still needs to be built with the correct server URL. This is suboptimal and will change in the future (part of [R-#1583]).
- adjust `URL` in .env to reflect the server the app will be running on.

To run TermIt, execute `docker-compose up` 
