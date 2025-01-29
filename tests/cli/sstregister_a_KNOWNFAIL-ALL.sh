#!/bin/bash

sst-register -a

retVal=$?
if [ $retVal -ne 134 ]; then
  echo "ERROR: $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
