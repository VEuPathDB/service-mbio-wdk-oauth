#!/bin/bash
####################################################################
##
##  Checks out MicrobiomeDB projects and sets branches as
##  appropriate for the preferred build.
##
##  NOTE: this is a work in progress; currently can use master
##    for most projects but some have development branches for
##    Java 21 + Tomcat 9.x deployment (see below).
##
####################################################################

dbPlatform=$1
if [ "$dbPlatform" = "oracle" ] || [ "$dbPlatform" = "postgres" ]; then
  echo "Setting project branches for $dbPlatform"
else
  echo "USAGE: cloneProjects.sh <dbPlatform>"
  echo "   dbPlatform must be 'oracle' or 'postgres'"
  exit 1
fi

scriptDir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
projectHome=$(realpath $scriptDir/../project_home)

echo "Creating $projectHome"
mkdir -p $projectHome
cd $projectHome

projects=(\
  CBIL \
  EbrcModelCommon \
  EbrcWebsiteCommon \
  EbrcWebSvcCommon \
  FgpUtil \
  install \
  MicrobiomeDatasets \
  MicrobiomeModel \
  MicrobiomePresenters \
  MicrobiomeWebsite \
  OAuth2Server \
  ReFlow \
  WDK \
  WSF \
)

for project in "${projects[@]}"; do
  if [ -d $project ]; then
    echo "Skipping clone of ${project}; already exists"
    echo "Checking out master branch of $project"
    cd $project
    git pull
    git checkout master
    cd ..
  else
    echo "Cloning $project"
    git clone git@github.com:VEuPathDB/${project}.git
  fi
done

j21tc9Projects=(\
  install \
  WDK \
  EbrcWebsiteCommon \
  MicrobiomeWebsite \
  OAuth2Server \
)

for project in "${j21tc9Projects[@]}"; do
  echo "Checking out j21tc9 branch of $project"
  cd $project
  git pull
  git checkout j21tc9
  cd ..
done

# handle projects with special branches for postgres
if [ "$dbPlatform" = "postgres" ]; then

  pgProjects=(\
    EbrcModelCommon \
  )

  for project in "${pgProjects[@]}"; do
    echo "Checking out standalone-mbio-postgres branch of $project"
    cd $project
    git pull
    git checkout standalone-mbio-postgres
    cd ..
  done
fi
