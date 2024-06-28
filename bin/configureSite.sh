#!/bin/bash

# check for input var existance
if [ "$1" = "" ] || [ "$2" = "" ]; then
  echo
  echo "USAGE: configureSite.sh <filesDir> <siteDir>"
  echo
  exit 1
fi

# check args are directories
for dir in "$1" "$2"; do
  if [ ! -d $dir ]; then
    echo "Error: $dir is not a directory"
    exit 2
  fi
done

echo "Configuring site..."

# vars for real location names, trimming trailing slashes
filesDir=`realpath $1`
siteDir=`realpath $2`

for path in `find $filesDir`; do
  # skip files dir
  if [ "$path" != "$filesDir" ]; then

    # relative path will be appended to source and destination dirs
    relativePath=${path#"$filesDir/"}

    # mkdir for dirs
    if [ -d $path ]; then
      echo "Creating directory: $siteDir/$relativePath"
      mkdir -p $siteDir/$relativePath

    # cp for non-template files
    elif ! [[ $(basename $relativePath) =~ "tmpl" ]]; then
      echo "Copying file:       $siteDir/$relativePath"
      cp $filesDir/$relativePath $siteDir/$relativePath

    # substitute environment vars in templates
    else
      # copy template to its destination location
      destPath=$siteDir/${relativePath%\.tmpl}
      cp $filesDir/$relativePath $destPath

      # loop through environment vars, filling each one
      echo "Filling template:   $destPath"
      for var in `env`; do
        # split env output to get keys and values
        varName=$(echo $var | awk -F'=' '{ print $1 }' -)
        varValue=$(echo $var | sed "s/$varName\=//")

        # escape chars and add custom file macro shell ('%%') to keys
        macro="$(printf '%s\n' "%%${varName}%%" | sed -e 's/[]\/$*.^[]/\\&/g')"
        value="$(printf '%s\n' "$varValue" | sed -e 's/[\/&]/\\&/g')"

        # perform substitution to temp file, then copy back
        sed "s/$macro/$value/g" $destPath > ${destPath}.tmpTmpl
        mv ${destPath}.tmpTmpl $destPath
      done 
    fi
  fi
done
