#!/bin/bash
#EXT_TEST TEST_FILE_PARAM 13.1
#EXT_TEST TEST_FILE_DESC "Displays the help menu of SST 13.1"

sst --help

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

sst --help=verbose

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

echo "PASS"
exit $retVal
