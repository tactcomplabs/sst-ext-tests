#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests the sst-info print-env command option"

sst-info --print-env

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit $retVal
