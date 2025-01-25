#!/bin/bash

sst-config --help

retVal=$?
if [ $retVal -ne 1 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit 0
