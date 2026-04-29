#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check action triggers for RankParallel: 4 ranks, 2 threads/rank for rank3, thread1"
#EXT_TEST TIMEOUT 30

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
CONFIG=$(realpath ../debug-console/test_Checkpoint_4ms.py)
RANKS=4
THREADS=2

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

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
# rank 3 thread 1 c7
rank 3
# CHECK 0 thread 1\n---- Rank3:Thread1: Entering interactive mode at time 1000000
thread 1
cd c7
cd xorshift
# printTrace action
trace w changed : 32 4 : w x y z : printTrace
setHandler 0 ae ac
# CHECK 1 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : printTrace
printWatchpoint 0
run 40us
rank 3
thread 1
unwatch 0
#set action
trace w changed : 32 4 : w x y z : set z 50
setHandler 1 ac ae
# CHECK 2 printWatchpoint 1\nWP1: TriggerCount 0 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : set c7/xorshift/z 50
printWatchpoint 1
run 40us
rank 3
thread 1
unwatch 1
#printStatus action
trace w changed : 32 0 : w x y z : printStatus
setHandler 2 ac ae
# CHECK 3 printWatchpoint 2\nWP2: TriggerCount 0 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 0 : w x y z  : printStatus
printWatchpoint 2
run 40us
rank 3
thread 1
unwatch 2
#interactive action
trace w changed : 32 4 : w x y z : interactive
setHandler 3 ac ae
# CHECK 4 printWatchpoint 3\nWP3: TriggerCount 0 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : interactive
printWatchpoint 3
run 40us
rank 3
thread 1
watchlist
unwatch 3
run
EOF


# Update this whenever adding checks in the command comments above
NUMCHECKS=5

# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np $RANKS sst --verbose=$VERBOSE -n $THREADS --interactive-start=0s $CONFIG"
echo $LAUNCH
#( $LAUNCH << EOF || exit 11 ) | tee $LOGFILE
( $LAUNCH 2>&1 << EOF || exit 11 ) | tee  $LOGFILE
replay $CMDFILE
confirm false
exit
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# spot checks
# First argument is the number of expected checks
${SPOTCHECKS} $NUMCHECKS $LOGFILE

RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: Test Failed with RC=$RC"
  exit $RC
fi

# ---- rank 3 thread 1 c2
# printTrace action
PSTR="LastTriggerRecord:@cycle10000000: SamplesLost=0: w = 24684 x = 0 y = 0 z = 0"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

# set action
PSTR="set c7/xorshift/z 50"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# printStatus
PSTR="CurrentSimCycle:  9000000"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# interactive
PSTR="Rank:3/4 Thread:1/2 (Triggered)"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

#PSTR=" Last Trigger: WP3: AC : c7/xorshift/w ..."
PSTR="3: TriggerCount 3 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

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
