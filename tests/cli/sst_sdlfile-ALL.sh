#!/bin/bash

sst --sdl-file=cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit 0
