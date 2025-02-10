#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests the num_threads option for executing a basic SDL file"
#EXT_TEST DEP "memHierarchy.Cache memHierarchy.MemController memHierarchy.simpleMem miranda.GUPSGenerator"

sst -n 2 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

sst --num-threads=2 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

echo "PASS"
exit 0
