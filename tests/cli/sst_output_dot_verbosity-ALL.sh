#!/bin/bash

sst --output-dot=foo.dot --dot-verbosity=9 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=8 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=7 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=6 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=5 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=4 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=3 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=2 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

sst --output-dot=foo.dot --dot-verbosity=1 cli-sdl.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi

echo "PASS"
exit 0
