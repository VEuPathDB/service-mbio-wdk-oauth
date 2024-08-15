# MicrobiomeDB Stand-Alone Website

This repo contains two primary resources:
1. Setup scripts, config files, and a Dockerfile to create a docker image which encapsulates the WDK and OAuth dependencies of MicrobiomeDB into a single service
2. A set of docker-compose yml files that combine the image in (1) with EDA, VDI, and other elements into a single stack, providing an entire MicrobiomeDB website

Two data provider solutions are available:
1. VEuPathDB Oracle DBs: Using SSH tunneling, you can access existing Oracle databases to provide AccountDB, UserDB, and AppDB data stores.
2. Locally stored PostgreSQL DBs: In this case, an additional PostgreSQL container is added to the compose stack, providing AcccountDB, UserDB, and AppDb schemas via a locally mounted (configurable) storage directory.

## Prerequisites

This project has been tested in Linux and Mac environments but is untested on Windows.  To clone this project and others you will need git and bash.

Since the services run under Docker, you must have a local docker installation (e.g. [Docker Desktop](https://www.docker.com/products/docker-desktop)), but most other required software will be downloaded automatically during the build phase.

To access the deployed website, Traefik is used with a domain that resolves via DNS to locahost.  See 'Deploying the Microbiome Stack' for instructions.

To generate some configuration values and a private key file, you will need to use tooling in the OAuth2Server project.  To build and run these tools, you will need Java 11+ and Maven 3+.

## Building the WDK/OAuth Image

1. Clone this repo and `cd` into its main directory.
2. Decide whether you will connect to existing remote Oracle data stores or to local PostgreSQL data stores.
3. Run the script `bin/cloneProjects.sh <oracle|postgres>` to build out a project_home containing the project dependencies of MicrobiomeDB needed for your database platform.  Some of these projects may be private and require special github credentials to access.  Some of the projects are checked out as master but others are on branches (DB platform choice influences the branch in one repo).
4. Run `make docker`.  In certain cases, `make dockernocache` is necessary but this is rare.
5. This will create a local docker image for WDK/OAuth tagged with `mbio-wdk:latest`.  If you want to be able to pull this image remotely you will have to take care of deploying it to DockerHub or another repository.

## Host Machine Setup

The stand-alone MicrobiomeDB docker compose stack relies heavily on bind mounts to directories on the parent machine.  There is a "standard" directory structure that holds the OAuth pkcs12 signature file, download files, tmp files, application logs, and persistent minio and postgres data (Oracle data remains on VEuPathDB servers as configured).  You must choose a root directory to store this data, then run the following script to build out the directory structure:

```
> bin/buildMountedDirs.sh <dataStorageRootDirectory>
```

There is only one configuration file required (other configuration is pulled from the runtime environment), the signing keys for OAuth bearer tokens.  See instructions here for how to generate this file, then move it to `<dataStorageRootDirectory>/secrets/oauth-keys.pkcs12`.  Note: you do not need to reclone the `OAuth2Server` project; it should already exist in `project_home/`.

If you do not already have a private key file for signing OAuth bearer tokens, see [the instructions here](https://github.com/VEuPathDB/OAuth2Server?tab=readme-ov-file#generating-private-keys-for-signing-bearer-tokens) to create the needed pkcs12 file, then move it to `<dataStorageRootDirectory>/secrets/oauth-keys.pkcs12`.

Use the same root directory value you used above for the $DATA_STORAGE_ROOT_DIR environment variable when configuring your compose stack below.

## Docker Compose Stack Configuration (runtime environment)

Before deploying the application, you must build a set of files that determine the runtime environment.  The `env.dev.<platform>.base` files contain most of what you need, but there are some custom values and secrets that cannot be kept in version control.  The values you need to fill in are documented in `env.dev.<platform>.sample` files.  Copy the `env.dev.<platform>.sample` file of your choice to `env.dev.<platform>.custom` and populate the values for the variables within.  See below for DB platform specific advice.

### Oracle (remote databases)

### PostgreSQL (local data storage)

## Deploying the MicrobiomeDB Stack

Running a dev stack locally involves two pieces:
1. Running traefik as a front-end router
2. Running the MicrobiomeDB stack

