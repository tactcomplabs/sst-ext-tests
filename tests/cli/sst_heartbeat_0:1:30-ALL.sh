#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests a 90 second heartbeat using %H:%M:%S syntax"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

# selecting count to run for a few seconds.
# A test component that has ability to specify its runtime in seconds would be more portable
log=sst_hearbeat_0:1:30.log
sst --heartbeat-wall-period=0:1:30 cli-sdl.py -- --count=7000000 > $log

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

# Check heartbeat actually happened
grep "Simulation Heartbeat:" $log
if [ $? -ne 0 ]; then
  echo "ERROR: no heartbeat"
  exit 1
fi

# passed: clean up
rm -f $log
echo "PASS"

exit 0
