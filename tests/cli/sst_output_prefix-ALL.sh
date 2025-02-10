#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests outputting files with a prefix"
#EXT_TEST DEP "memHierarchy.Cache memHierarchy.MemController memHierarchy.simpleMem miranda.GUPSGenerator"

sst --output-prefix-core=TESTPREFIX cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
