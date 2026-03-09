#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Full json loader test"
#EXT_TEST DEP "coreTestElement.message_mesh.enclosing_component"

json_file=$(basename "$0" .sh).json

sst --run-mode=init $json_file

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
