#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.0
#EXT_TEST TEST_FILE_DESC "Simple json loader test"
#EXT_TEST DEP "coreTestElement.coreTestLinks"

json_file=$(basename "$0" .sh).json

sst --run-mode=init $json_file

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
