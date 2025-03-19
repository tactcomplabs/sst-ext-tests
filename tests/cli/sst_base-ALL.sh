#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Basic execution test suitable for all versions of SST"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

sst cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
