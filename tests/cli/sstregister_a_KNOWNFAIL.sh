#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests the known failure of the sst-register -a option"

sst-register -a

retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR: $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
