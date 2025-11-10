#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 13.0
#EXT_TEST TEST_FILE_DESC "Tests outputting the config graph as a dot file"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

sst --output-dot=foo.dot cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
