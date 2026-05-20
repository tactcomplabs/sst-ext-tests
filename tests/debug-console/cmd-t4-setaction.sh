#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Check that trace set action triggers with 4 threads"
#EXT_TEST TIMEOUT 30

DO_BASELINE=0
if [ $# -gt 0 ]; then
  DO_BASELINE=1
fi

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Convenience environment variables
set +u
if [[ -z "${CLEANUP}" ]]; then
CLEANUP=1
fi
if [[ -z "${VERBOSE}" ]]; then
  VERBOSE=0
fi

set -u

# Common settings
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint_4ms.py"
RANKS=1
THREADS=4

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
CKPTPREFIX=ckpt_$TNAME
SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

# Console commands
cat << EOF > $CMDFILE
cd c0
cd xorshift
trace w changed : 32 4 : w x y z : set z 50
setHandler 0 ae ac
# CHECK 0 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : .?c0/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : .*x .*y .*z  : set c0/xorshift/z 50
printWatchpoint 0
trace w changed : 32 4 : w x y z : printTrace
setHandler 1 ae ac
# CHECK 1 printWatchpoint 1\nWP1: TriggerCount 0 : AC AE : .?c0/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : .*x .*y .*z  : printTrace
printWatchpoint 1
run
EOF


# Update this whenever adding checks in the command comments above
NUMCHECKS=2

# Launch the program to start interactive mode at time 0
if [ $DO_BASELINE -eq 1 ]; then
  echo "baseline only"
  LAUNCH="sst --verbose=$VERBOSE -n $THREADS $CONFIG"
else
  LAUNCH="sst --verbose=$VERBOSE -n $THREADS --interactive-start=0s $CONFIG"
fi
echo $LAUNCH

if [ $DO_BASELINE -eq 1 ]; then
  $LAUNCH | tee $LOGFILE
else
  ( $LAUNCH << EOF || exit 11 ) | tee $LOGFILE
  replay $CMDFILE
EOF
fi

RC=$?

echo $TNAME Complete

# Check result
if [ $RC -ne 0 ]; then
  echo "ERROR $TNAME returned $RC"
  exit $RC
fi

if [ $DO_BASELINE -eq 0 ]; then
  # spot checks
  # First argument is the number of expected checks
  ${SPOTCHECKS} $NUMCHECKS $LOGFILE
fi

RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: Test Failed with RC=$RC"
  exit $RC
fi

# Simulation Complete
PSTR="Simulation is complete, simulated time: 4.007 ms"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
  rm -rf $CKPTPREFIX
fi

wait
echo "PASS"
exit 0
