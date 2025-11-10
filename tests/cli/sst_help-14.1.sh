#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 14.1
#EXT_TEST TEST_FILE_MAXVER 14.1
#EXT_TEST TEST_FILE_DESC "Displays the help menu of SST 14.1"

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
