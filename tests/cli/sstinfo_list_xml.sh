#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests the sst-info xml output"

sst-info -x

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

if ! [ -f SSTInfo.xml ]; then
  echo "File does not exist."
  echo "ERROR"
fi

echo "PASS"
exit $retVal
