#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Tst basic thread commands: thread, info"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

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
CONFIG="dbgsst15.py"
PSTR=""

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH 2>&1 << EOF | tee $LOGFILE || exit 1
info local
info all
thread 1
info local
thread 0
cd cp0
watch size changed
run
unwatch 0
run
# previous trace will trigger shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

# Avoid diff due to differences btwn mac and linux
#diff $LOGFILE $CHKFILE > /dev/null
#retVal=$?
#if [ $retVal -ne 0 ]; then
#  echo "ERROR in diff $LOGFILE $CHKFILE"
#  exit $retVal
#fi
#echo "Log file matches check file"

# Need one for each action
# Interactive
PSTR="Entering interactive mode at time 0"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="Rank 0/1, Thread 0/1"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# printTrace
PSTR="cp0"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# printStatus
PSTR="Rank 0/1, Thread 1/2"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR found fail string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "No fail string \"$PSTR\""

#set
PSTR="cp1"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# Simulation Complete
PSTR="Simulation is complete"
grep "$PSTR" $LOGFILE > /dev/null
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
