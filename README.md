# MicrobiomeDB Stand-Alone Website

This repo contains two primary resources:
1. Setup scripts, config files, and a Dockerfile to create a docker image which encapsulates the WDK and OAuth dependencies of MicrobiomeDB into a single service
2. A docker-compose.yml file that combines the image in (1) with EDA and VDI elements into a single stack, providing an entire MicrobiomeDB website

## Building the WDK/OAuth Image

1. Clone this repo.
2. Run the script bin/cloneProjects.sh to build out a project_home containing the GUS project dependencies of MicrobiomeDB.  Some of these projects may be private and require special github credentials to access.  Note some of the projects are checked out as master and a few are on j21tc9 branches.  The OAuth2Server project is also cloned as part of the image build and is also on a j21tc9 branch.
3. Run `make docker` or `make dockernocache` if you've made recent changes.
4. This will create a local docker image for WDK/OAuth tagged with `mbio-wdk:latest`.  If you want to run this image remotely you will have to take care of deploying it to DockerHub or another repository.

## Deploying the MicrobiomeDB Stack

### Development (while VEuPathDB still exists)

To run the full stack, you first need a configuration file containing the required environment variables needed by the stack.  Start with the provided `env.sample` (TODO: add advice for variable population).

Running a dev stack locally involves three pieces:
1. Running sshuttle so VEuPathDB resources are still available (this will be true until we migrate everything to postgres)
2. Running traefik as a front-end router
3. Running the stack

> sshuttle {configuration proprietary: see systems team>}
