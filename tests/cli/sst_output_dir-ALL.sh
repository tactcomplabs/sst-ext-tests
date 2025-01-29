#!/bin/bash

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
