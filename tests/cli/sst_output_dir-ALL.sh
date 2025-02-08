#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests outputting run data to a specific directory""

rm -Rf ./FOO

sst --output-directory=./FOO cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

if [ ! -d "./FOO" ]; then
  echo "ERROR : Directory does not exist!"
fi

rm -Rf ./FOO

echo "PASS"
exit 0
