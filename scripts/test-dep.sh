#!/bin/bash
#
# test-dep.sh
# Given a fully qualified path to a test file (.sh or .py), examines
# the file header and searches the local SST install for the existence
# of the component dependency list
#
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# Check for arguments
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    echo "Usage: $0 <filename>"
    exit 1
fi

# Check if file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

# Process the file
COMPS=`grep "#EXT_TEST DEP" "$1" | sed 's/#EXT_TEST DEP "\(.*\)"/\1/' | tr ' ' '\n'`

for C in $COMPS;do
  VAL=`sst-info -q $C | grep "ELEMENT LIBRARY"`
  if [ -z "$VAL" ]; then
    echo "NO_RUN"
    exit -1
  fi
done;

echo "RUN"
exit 0

# EOF
