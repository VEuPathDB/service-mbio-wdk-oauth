#!/bin/bash
####################################################################
##
## resolveBuildProjects.sh <build_type>
##
## This script ensures the projects in /workspace/project_home are
## configured as specified by build_type argument.
##
## Note this script assumes a version of build.projects.versions
## exists in /workspace/project_home.  The eventual and possibly
## corrected build.projects.versions will live in /workspace.
##
## If build_type = "local" then the projects in project_home are
## examined and a new build.projects.versions file is produced with
## the current branch and commit information in those projects.
## NOTE: local changes are not noticed or documented!
##
## If build_type has any other value or no value, the contents of
## project_home are discarded and needed projects are cloned as
## defined in the existing build.projects.versions file.
##
####################################################################

versionsFile=build.projects.versions

cd /workspace

git config --global "advice.detachedHead" "false"

if [ ! -e project_home ]; then
  echo "Error: No project_home exists in /workspace.  Please check the Dockerfile"
  exit 1
fi

cd project_home

if [ ! -e $versionsFile ]; then
  echo "Error: No $versionsFile exists in /workspace/project_home.  Please check the Dockerfile"
  exit 2
fi

# parse the existing versions file
while IFS= read -r line; do

  projectDef=( $(echo $line | sed 's/:/ /g') )
  repo=${projectDef[0]}
  branch=${projectDef[1]}
  hash=${projectDef[2]}

  if [ "$1" = "local" ]; then

    # build_type = "local"
    #   Use the projects copied into project_home; check they are all present,
    #   that there are no local checkouts, and then generate a new versions file

    if [ ! -e $repo ]; then
      echo "Error: Local build type specified, but $repo does not exist in project_home."
      exit 3
    fi

    cd $repo

    if [ "$(git status -s | wc -l)" != "0" ]; then
      echo "Error: Local build type specified; local commits exist in $repo.  Please commit changes to a branch, then try again."
      exit 4
    fi

    # get the branch and commit hash for the version of the current project
    echo "$(pwd | xargs basename):$(git rev-parse --abbrev-ref HEAD):$(git log -1 | head -1 | awk '{ print $2 }')" >> /workspace/$versionsFile

    cd ..

  else

    # build_type != "local"
    #   Check out the projects and put them on the correct branch and commit

    # delete any existing repo; start fresh
    rm -rf $repo

    # clone the repo (add creds since some repos are private)
    git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/VEuPathDB/$repo.git

    # check out the specified hash (make sure branch is a thing too)
    cd $repo
    git checkout $branch || (echo "Error: Branch $branch does not exist on repo $repo"; exit 5)
    git checkout $hash || (echo "Error; Hash $hash does not exist on repo $repo"; exit 6)
    cd ..

    echo "$line" >> /workspace/$versionsFile

  fi

done < $versionsFile

# remove the one in project_home; corrected version lives in /workspace
rm $versionsFile

