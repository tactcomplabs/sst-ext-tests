#!/bin/bash
#
# Derives the SST major version
# In SST 14.0.0; this script returns "14"
#

sst --version | awk '{print $3}' | tr -d '()' | awk '{split($0,a,"."); print a[1]}'

# EOF
