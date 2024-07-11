#!/bin/bash
####################################################################
##
##  Checks out MicrobiomeDB projects and sets branches as
##  appropriate for the current build.
##
##  NOTE: this is a work in progress; currently can use master
##    for most projects but some have development branches for
##    Java 21 + Tomcat 9.x deployment (see below).
##
####################################################################

releaseBranch=$1
if [ "$releaseBranch" = "" ]; then
    releaseBranch=master
fi
echo "Using release branch '$releaseBranch'"

scriptDir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
projectHome=$(realpath $scriptDir/../project_home)

echo "Creating $projectHome"
mkdir -p $projectHome
cd $projectHome

if [ ! -d .tsrc ]; then
    echo "Initializing project_home"
    tsrc init https://github.com/VEuPathDB/tsrc.git --group microbiomeSite
else
    echo "Skipping project_home initialization; already initialized"
fi

echo "Checking out all projects to $releaseBranch"
tsrc foreach -- git checkout $releaseBranch

git clone https://github.com/VEuPathDB/OAuth2Server.git

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
