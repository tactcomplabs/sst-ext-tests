#!/bin/bash
#
# test-timeout.sh
# Given a fully qualified path to a test file (.sh or .py), examines
# the file header for EXT_TEST TIMEOUT VALUE
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
SEARCH=`grep "#EXT_TEST TIMEOUT" "$1"`
if [ -n "$SEARCH" ]; then
  TIMEOUT=`grep "#EXT_TEST TIMEOUT" "$1" | sed -n 's/.*TIMEOUT \([0-9]*\).*/\1/p'`
  echo $TIMEOUT
else
  echo "0"
fi

wait

# EOF
