#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Displays the help menu for all versions of SST"

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
