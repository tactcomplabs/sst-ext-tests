#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Check for warning on Empty Rank Sync"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG=$(realpath ../debug-console/dbg_4comp.py)

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np 2 sst -n 2 --interactive-start --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH | tee $LOGFILE

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# WARNING
PSTR="WARNING: EmptyRankSync"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# Simulation Complete
PSTR="Simulation is complete, simulated time: 1.0017 ms"
egrep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE
fi

wait
echo "PASS"
exit $retVal
