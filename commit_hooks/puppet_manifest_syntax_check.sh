#!/bin/bash

# This script expects $1 to be passed and for $1 to be the filesystem location
# to a puppet manifest file for which it will run syntax checks against.

syntax_errors=0
error_msg=$(mktemp /tmp/error_msg_puppet-syntax.XXXXX)

if [ $2 ]; then
    module_path=$(echo $1 | sed -e 's|'$2'||')
else
    module_path=$1
fi

# Get list of new/modified manifest and template files to check (in git index)
# Check puppet manifest syntax
echo -e "Checking puppet manifest syntax for $module_path..."
puppet parser validate --color=false $1 2>&1 > $error_msg
if [ $? -ne 0 ]; then
    syntax_errors=`expr $syntax_errors + 1`
    cat $error_msg
    echo -e "Error: puppet syntax error in $module_path (see above)"
fi
rm -f $error_msg

if [ "$syntax_errors" -ne 0 ]; then
    echo -e "Error: $syntax_errors syntax error(s) found in puppet manifests. Commit will be aborted."
    exit 1
fi

exit 0
