# MicrobiomeDB Stand-Alone Website #

This repo contains two primary resources:
1. Setup scripts, config files, and a Dockerfile to create a docker image which encapsulates the WDK and OAuth dependencies of MicrobiomeDB into a single service
2. A set of docker-compose yml files that combine the image in (1) with EDA, VDI, and other elements into a single stack, providing an entire MicrobiomeDB website

Two data provider solutions are available:
1. VEuPathDB Oracle DBs: Using SSH tunneling, you can access existing Oracle databases to provide AccountDB, UserDB, and AppDB data stores.
2. Locally stored PostgreSQL DBs: In this case, an additional PostgreSQL container is added to the compose stack, providing AcccountDB, UserDB, and AppDb schemas via a locally mounted (configurable) storage directory.

## Prerequisites ##

This project has been tested in Linux and Mac environments but is untested on Windows.  To clone this project and others you will need git and bash.

Since the services run under Docker, you must have a local docker installation (e.g. [Docker Desktop](https://www.docker.com/products/docker-desktop)), but most other required software will be downloaded automatically during the build phase.

To generate some configuration values and a private key file, you will need to use tooling in the OAuth2Server project.  To build and run these tools, you will need Java 11+ and Maven 3+ (make sure both are in your $PATH and that $JAVA_HOME is set and correct).

## Building the WDK/OAuth Image ##

1. Clone this repo and `cd` into its main directory.
2. Decide whether you will connect to existing remote Oracle data stores or to local PostgreSQL data stores.
3. Run the script `bin/cloneProjects.sh <oracle|postgres>` to build out a project_home containing the project dependencies of MicrobiomeDB needed for your database platform.  Some of these projects may be private and require special github credentials to access.  Some of the projects are checked out as master but others are on branches (DB platform choice influences the branch in one repo).
4. Run `make docker` (will take 5-10 minutes). In certain cases, `make dockernocache` is necessary but this is rare.
5. NOTE: To build the VEuPathDB software, you will need to set Github credentials with proper permissions in your build environment.  [See here for how to create and set these values](https://veupathdb.atlassian.net/wiki/spaces/TECH/pages/47841323/Create+a+Github+user+token).
6. This will create a local docker image for WDK/OAuth tagged with `mbio-wdk:latest`.  If you want to be able to pull this image remotely you will have to take care of deploying it to DockerHub or another repository.

## Host Machine Setup ##

### Create Mounted Directory Structure ###

The stand-alone MicrobiomeDB docker compose stack relies heavily on bind mounts to directories on the parent machine.  There is a "standard" directory structure that holds the OAuth pkcs12 signature file, download files, tmp files, application logs, and persistent minio and postgres data (Oracle data remains on VEuPathDB servers as configured).  You must choose a root directory to store this data, then run the following script to build out the directory structure:

```
> bin/buildMountedDirs.sh <dataStorageRootDirectory>
```

Be sure to use the same root directory value you used above for the $DATA_STORAGE_ROOT_DIR environment variable when configuring your compose stack below.

### Create Bearer Token Signing Keys ###

Besides the runtime environment variable declaration files (env files), there is only one configuration file needed; it contains the asymmetric signing keys for OAuth bearer tokens.  Run the following commands to generate this file and move it to the correct location.

```
> cd project_home/OAuth2Server
> bin/createPrivateKeyFile.sh <pass_phrase_for_access>
> mv ecKeys.*.pkcs12 <dataStorageRootDirectory>/secrets/oauth-keys.pkcs12
```

Be sure to use the same pass phrase value you used above for the $OAUTH_SIGNING_KEY_STORE_PW environment variable when configuring your compose stack below.

### Download and Start Traefik ###

To access the deployed website, Traefik is used with a domain (*.local.apidb.org) that resolves via DNS to localhost (127.0.0.1).  To download and start our custom Traefik container, run the following in a separate terminal in a directory of your choosing:

```
> git clone git@github.com:VEuPathDB/docker-traefik.git
> cd docker-traefik
> docker network create traefik
> docker compose up
```

Note your DNS provider must resolve *.local.apidb.org to localhost.  To test this, run (on Linux):

```
> nslookup any.local.apidb.org
```

You should see 127.0.0.1 as the resolved IP Address.  If not you may need to adjust your DNS settings.  Google's DNS (8.8.8.8) has been shown to resolve this domain properly.

Fully test traefik by putting `https://traefik.local.apidb.org:8443/` in your browser.  You should get the traefik console.

## SMTP Configuration
A configured SMTP server is required for the standalone site to send e-mails. This is required for the application to:
1. Sending a temporary password when user is registered
2. Sending notifications when dataset access requests are updated
3. Send error e-mails to site administrators

For development environments, many SMTP providers allow free use up to a fixed number of e-mails per day.

### Using MailerSend
[MailerSend](https://app.mailersend.com) provides 100 e-mails per day using their SMTP services. In order to use it in a dev environment:
1. Register a new account
2. Verify your e-mail
3. After verifying your e-mail, you should have a trial domain. Navigate to your trial domain.
4. Once on the page for the Domain, scroll to the SMTP section, and click the "Manage" button
5. Using the information shown, fill out the following environment variables in the `env.dev.<platform>.custom` file
```
SMTP_HOST=smtp.mailersend.net
SMTP_USERNAME=<user>
SMTP_PASSWORD=<password>
SMTP_TLS=true
SMTP_PORT=<port>
HELP_EMAIL=test@<mailsender-trial-domain-name>
```

## Docker Compose Stack Configuration (runtime environment) ##

Before deploying the application, you must build a set of files that determine the runtime environment.  The `env.dev.<platform>.base` files contain most of what you need, but there are some custom values and secrets that cannot be kept in version control (GitHub).  The values you need to fill in are documented in `env.dev.<platform>.sample` files.  Copy your platform's `env.dev.<platform>.sample` file to `env.dev.<platform>.custom` and populate the values for the variables within.  In this section, we discuss DB-platform-agnostic config values.  See below for DB-platform-specific advice.

```
  Values we already know:
    DATA_STORAGE_ROOT_DIR: Set this to the value you passed to buildMountedDirs.sh
    OAUTH_SIGNING_KEY_STORE_PW: Set this to the value you passed to createPrivateKeyFile.sh

  Values that must be newly created:
    WDK_OAUTH_CLIENT_SECRET=
    SERVICE_OAUTH_CLIENT_SECRET=
    ADMIN_AUTH_TOKEN=
    WDK_SECRET_KEY=
```

The four values above must be long enough random values to be sufficiently secure.  The client secrets enforce this programmatically; the admin token and WDK secret key are not checked.  To generate random values of sufficient length, please run the following script:

```
> project_home/OAuth2Server/bin/createHmacSecretValue.sh
```

### Oracle (remote databases)

The env values in `env.dev.ora.base` configure your local MicrobiomeDB to point at the following DBs:

```
  AccountDB: acctdbN
  UserDB:    cecommDevN
  AppDB:     eda-inc
```

To access alternative databases, you will need to change multiple connection settings in that file.  If those are OK, then you need only set ACCT, USER, and APP DB login and password values as you would in a dev site.

We access the DBs via SSH tunneling.  You must set the following values to enable this:

```
TUNNEL_HOST= # host you will tunnel through
TUNNEL_PORT= # port SSH is enabled on (ask systems if you don't know)
TUNNEL_USER= # user used to log into the servers
```

To forward your SSH keys for login authentication, you need to have ssh-agent running.  To test this, run the following; it should display at least one active key.

```
> ssh-add -l
```

Also, SSH Agent is handled differently on Mac OSX, requiring custom settings for SSH Socket.  If you are on Mac, uncomment the following two lines in `env.dev.ora.custom`:

```
SSH_AUTH_SOCKET_SOURCE=/run/host-services/ssh-auth.sock
SSH_AUTH_SOCKET_TARGET=/ssh-agent
```

The following two values are related to VDI configuration (user dataset installation).  To work independently of other developers, you must have a dedicated pair of VDI schemas assigned to you, or agree to share a pair of schemas.

```
# set "beta_s" here if your VDI schemas are vdi_control_beta_s and vdi_datasets_beta_s
VDI_SCHEMA_SUFFIX=

# must be the password for the control schema user
DB_CONNECTION_PASS_MICROBIOME=
```

Important Note: Once you decide on a VDI schema name, you must create an installation directory for VDI with the same name, prior to starting up the service, as follows:

```
> mkdir -p <dataStorageRootDirectory>/userDatasets/vdi_datasets_<vdiSchemaSuffix>
```

### PostgreSQL (local data storage)

There are two variables needed to configure postgres. These values are used as root credentials and to access the database in the EDA and WDK. 

In a production environment, these should be set to sufficiently secure values, similar to the secrets above. In dev, they can be set to 
```
POSTGRES_ROOT_USER=
POSTGRES_ROOT_PASSWORD=

```

## Deploying the MicrobiomeDB Stack

Please review the following checklist before continuing:
1. Domains like `any.local.apidb.org` resolve to localhost (127.0.0.1) on your machine.  Check with `nslookup any.local.apidb.org`
2. The Traefik container is still running per instructions above
3. You have configured your `env.dev.<platform>.custom` file per instructions above

Good job!  You can start up the MicrobiomeDB stack with the command below corresponding to your DB platform:

```
> make oracleup
-OR-
> make postgresup
```

Wait until the docker compose logs say "Services running...".  If all goes well, you should be able to access the local MicrobiomeDB website at [https://mbio-dev.local.apidb.org:8443](https://mbio-dev.local.apidb.org:8443).

To bring the stack back down, run:

```
> make oracledown
-OR-
> make postgresdown
```



