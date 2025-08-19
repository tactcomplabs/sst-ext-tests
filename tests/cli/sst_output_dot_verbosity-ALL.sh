#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests outputting config graph graph data to a dot file with verbosity"
#EXT_TEST DEP "coreTestElement.coreTestComponent"
#EXT_TEST TIMEOUT 300

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
