#!/bin/bash

sst --output-directory=./FOO cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
