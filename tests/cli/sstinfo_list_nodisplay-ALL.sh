#!/bin/bash

sst-info -n

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit $retVal
