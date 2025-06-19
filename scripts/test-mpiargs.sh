#!/bin/bash
#
# test-mpiargs.sh
# Given a fully qualified path to a test file (.sh or .py), examines
# the file header for EXT_TEST MPIARGS "VALUE"
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
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
echo `grep -o "#EXT_TEST MPIARGS.*" "$1" | sed 's/#EXT_TEST MPIARGS//'`
exit 0

parentheses_value=$(grep -o "#EXT_TEST MPIARGS.*" "$1" | sed -n 's/.*(\(.*\)).*/\1/p')
if [ -z "$parentheses_value" ]; then
  quoted_value=$(grep -o "#EXT_TEST MPIARGS.*" "$1" | sed -n 's/.*"\(.*\)".*/\1/p')
  if [ -n "$quoted_value" ]; then
    echo "$quoted_value"
    exit 0
  fi
else
  exit 0
fi

exit 0

# EOF
