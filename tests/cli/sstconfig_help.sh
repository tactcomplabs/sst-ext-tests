#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests printing the sst-config help menu"

sst-config --help

retVal=$?
if [ $retVal -ne 1 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit 0
