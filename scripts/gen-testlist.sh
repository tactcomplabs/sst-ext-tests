#!/bin/bash
#
# gen-testlist.sh
# Used by local CMakeLists.txt to generate a test list given
# a specific sst version number. Currently non-recursive.
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# Check for arguments
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    echo "Usage: $0 <sst-version-number>"
    exit 1
fi

testlist=""
for f in *.sh; do
  awk -v sstver=$1 -v dbg=0 '
    BEGIN { min=0.0; max=9999.0}
    /EXT_TEST TEST_FILE_MINVER/ {min=$3}
    /EXT_TEST TEST_FILE_MAXVER/ {max=$3}
    END { \
      rangeOK = sstver>=min && sstver<=max; \
      devOK = sstver=="DEV" && max>=999.0; \
      rc = rangeOK || devOK ? 0 : 1; \
      if (dbg==1) {printf("sstver=%2.1f\tmin=%2.1f\tmax=%2.1f\trc=%d\n", sstver, min, max, rc)}; \
      exit(rc)}' $f
  if [ $? -eq 0 ]; then
    testlist="${testlist}$f "
  fi
done

echo $testlist

exit 0

# EOF
