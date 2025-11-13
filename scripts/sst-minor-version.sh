#!/bin/bash
#
# Derives the SST major version
# In SST 14.1.0; this script returns "1"
#

# Allow for test audit without messing with sst binary
if [ "$#" == 1 ]; then
    sstver="SST-Core Version ($1)"
else
    sstver=$(sst --version)
fi

echo $sstver | awk '{print $3}' | tr -d '()' | awk '{split($0,a,"."); print a[2]}'

# EOF
