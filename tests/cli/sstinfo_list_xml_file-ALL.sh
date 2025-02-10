#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests the sst-info XML output with a specified file"

sst-info -x -o foo.xml

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

if ! [ -f foo.xml ]; then
  echo "File does not exist."
  echo "ERROR"
fi

echo "PASS"
exit $retVal
