# TermIt docker
TermIt docker serves to spin off a TermIt deployment, consisting of :
- GraphDB (database)
- TermIt (backend)
- TermIt UI (frontend)

## Prerequisities
First, You should have Docker installed (and accessible under current user).
Second, You need a valid GraphDB Free installation package (or a valid SE or EE license).

Edit `docker-compose.yml`:
- change backend.build.context and frontend.build.context to point to your local directories of 
TermIt (clone of `https://github.com/kbss-cvut/termit`) and TermIt UI (clone of `https://github.com/kbss-cvut/termit-ui`) 
respectively.
- download GraphDB Free ZIP and place it into the `graphdb` folder.
- set `services.graphdb.build.args.version` to the respective GraphDB version, e.g. 9.3.3

To build docker images, execute `docker-compose build`
Then, to run the whole TermIt platform, execute `docker-compose up` 
