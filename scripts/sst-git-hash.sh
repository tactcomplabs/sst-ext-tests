#!/bin/bash
#
# Derives the SST git hash
# SST-Core Version (-dev, git branch : HEAD, SHA: 42b92ad9f44436a03fb3e30899f0aebb378ca987)
# returns, 42b92ad9f44436a03fb3e30899f0aebb378ca987
#

sst --version | awk '{print $9}' | tr -d '()' | awk '{split($0,a,"."); print a[1]}'

# EOF
