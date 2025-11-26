#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 14.1
#EXT_TEST TEST_FILE_DESC "Tests a 1 second heartbeat"
#EXT_TEST DEP "coreTestElement.coreTestComponent"
#EXT_TEST TIMEOUT 90

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# selecting count to run for a few seconds.
# A test component that has ability to specify its runtime in seconds would be more portable
log=sst_hearbeat_1s.log

# IMPORTANT: This test must be greater than 1s (wall clock) and may fail on fast systems.
# Increase the --work option to increase test time.
# If this becomes more problematic, we should replace the component with one that we can specify
# a minimum wall clock run time.
sst --heartbeat-wall-period=1s cli-sdl.py -- --work=3000 | tee $log

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
