#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests printing the sst-config help menu"

sst-config --help

retVal=$?
if [ $retVal -ne 1 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit 0
