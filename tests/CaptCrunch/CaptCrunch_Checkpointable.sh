#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Tests CaptCrunch checkpointable flag"
#EXT_TEST DEP "captcrunch"

TEST_NAME=CaptCrunch_Checkpointable


CP=`sst-info captcrunch | grep "Checkpointable" | awk '{print $2}'`

if [[ "$CP" == "false" ]]; then
  echo "ERROR"
  exit -1
fi

echo "PASS"
exit 0

# EOF
