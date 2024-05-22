#!/bin/bash

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
