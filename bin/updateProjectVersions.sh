#!/bin/bash
####################################################################
##
## updateProjectVersions.sh
##
## This script updates build.projects.versions to reflect the most
## recent commits on the appropriate branch for each project needed
## in the docker build.  As an input to the image build, this ensures
## reproducibility in the build and also helps maximize cache use.
##
####################################################################

# get to the parent directory of the bin dir
cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/..

inputFile=build.projects.versions
tmpFile=tmp.$(date +%s%3N)
oldLineCount=$(wc -l $inputFile | awk '{ print $1 }')

touch $tmpFile

while IFS= read -r line; do

  projectDef=( $(echo $line | sed 's/:/ /g') )
  repo=${projectDef[0]}
  branch=${projectDef[1]}
  oldHash=${projectDef[2]}

  newHash=$(curl -L --no-progress-meter \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/VEuPathDB/$repo/commits/$branch \
    | jq '.sha' | sed 's/"//g')

  if [ "$newHash" = "null" ]; then
    # if check failed, skip this line; we will not overwrite the old file
    echo "$repo/$branch : Failed to fetch latest commit hash"
  else
    if [ "$oldHash" = "$newHash" ]; then
      echo "$repo/$branch : No update from $oldHash"
    else
      echo "$repo/$branch : Updating from $oldHash to $newHash"
    fi

    echo "${repo}:${branch}:${newHash}" >> $tmpFile
  fi

done < $inputFile

newLineCount=$(wc -l $tmpFile | awk '{ print $1 }')

if [ "$oldLineCount" != "$newLineCount" ]; then
  echo "Error: failed to fetch all commit hashes and did not update file.  Partial update may be found in $tmpFile"
else
  mv $tmpFile $inputFile
  echo "Done."
fi
