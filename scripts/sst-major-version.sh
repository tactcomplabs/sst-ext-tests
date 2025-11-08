#!/bin/bash
#
# Derives the SST major version
# In SST 14.0.0; this script returns "14"
#

# Allow for test audit without messing with sst binary
if [[ -n "$SST_EXT_TESTS_FORCE_VERSION" ]]; then
    sstver="SST-Core Version ($SST_EXT_TESTS_FORCE_VERSION)"
else
    sstver=$(sst --version)
fi

echo $sstver | awk '{print $3}' | tr -d '()' | awk '{split($0,a,"."); print a[1]}'

# EOF
