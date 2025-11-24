#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 14.1
#EXT_TEST TEST_FILE_DESC "Tests a 1 second heartbeat"
#EXT_TEST DEP "coreTestElement.coreTestComponent"


# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# selecting count to run for a few seconds.
# A test component that has ability to specify its runtime in seconds would be more portable
log=sst_hearbeat_1s.log
sst --heartbeat-wall-period=1s cli-sdl.py -- --count=200000 | tee $log

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
