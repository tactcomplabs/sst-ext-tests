#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests the baseline sst-config"

sst-config

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit $retVal
