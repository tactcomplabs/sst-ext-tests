#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check set action trigger and trace buffer"
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
#RANKS=4
THREADS=1

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
cd c2
cd xorshift
# printTrace action
ls -l
trace w changed : 32 4 : w x y z : printTrace
setHandler 0 ac ae
# CHECK 0 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : /c2/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : printTrace
printWatchpoint 0
run 40us
ls -l
printTrace 0
unwatch 0
#set action
ls -l
trace w == 50357088 : 32 4 : w x y z : set w 50
ls -l
# CHECK 1 printWatchpoint 1\nWP1: TriggerCount 0 : ALL : /c2/xorshift/w == 50357088  : bufsize = 32 postDelay = 4 : w x y z  : set c2/xorshift/w 50
printWatchpoint 1
run 80us
printTrace 1
unwatch 1
#interactive action
ls -l
trace w changed : 32 8 : w x y z : interactive
setHandler 2 ac ae
# CHECK 2 printWatchpoint 2\nWP2: TriggerCount 0 : AC AE : /c2/xorshift/w CHANGED  : bufsize = 32 postDelay = 8 : w x y z  : interactive
printWatchpoint 2
run 40us
watchlist
printTrace 2
unwatch 2

shutd
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=3

# Launch the program to start interactive mode at time 0
#LAUNCH="mpirun ${MPIOPTS} --np $RANKS sst --verbose=$VERBOSE -n $THREADS --interactive-start=0s $CONFIG"
LAUNCH="sst --verbose=$VERBOSE -n $THREADS --interactive-start=0s $CONFIG"

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

# ---- rank 1 thread 0 c2
# printTrace action
PSTR="LastTriggerRecord:@cycle10000000: SamplesLost=0: w = 24684 x = 0 y = 0 z = 0"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

PSTR="buf\[0\] AE @2000000 (-) w = 0 x = 12 y = 0 z = 0"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

PSTR="buf\[5\] AE @26000000 (+) w = 24684 x = 0 y = 0 z = 24684"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""


# set action
PSTR="LastTriggerRecord:@cycle80000000: SamplesLost=0: w = 50357088 x = 24684 y = 50356992 z = 24588"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="buf\[0\] BE @82000000 (-) w = 50 x = 50356992 y = 24588 z = 50357088"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

PSTR="buf\[15\] AE @114000000 (-) w = 50332478 x = 50 y = 1604433 z = 52132702"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

# Simulation end (shutdown)
PSTR="Simulation is complete, simulated time: 0 s"
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
