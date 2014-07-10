#!/bin/bash

# This script expects $1 to be passed and for $1 to be the filesystem location
# to a eyaml file for which it should be encrypted with eyaml.

errors=0
eyaml_output=$(mktemp /tmp/XXXXX.eyaml)
error_msg=$(mktemp /tmp/error_msg_eyaml.XXXXX)
module_path=$1

# Get list of new/modified manifest and template files to check (in git index)
# Encrypt EYAML file
echo -e "Encrypting eyaml for $module_path..."
eyaml encrypt -e $1 -o string 1>$eyaml_output 2>$error_msg
if [ $? -ne 0 ]; then
    cat $error_msg
    errors=`expr $errors + 1`
    echo -e "Error: Could not encrypt $module_path"
else
  if ! grep -q 'DEC::PK' $eyaml_output;
  then
    cat $eyaml_output > $module_path
    git add $module_path
  else
    errors=`expr $errors + 1`
    echo -e "Error: Some values remain unencrypted in $module_path"
  fi
fi
rm -f $error_msg
rm -f $eyaml_output

if [ "$errors" -ne 0 ]; then
    echo -e "Error: $errors encryption error(s) found in hiera eyaml. Commit will be aborted."
    exit 1
fi

exit 0
