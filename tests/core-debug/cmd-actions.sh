#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Check for interactive, printTrace, printStatus, and set actions"
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
CONFIG="dbgsst15.py"
PSTR=""

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH 2>&1 << EOF | tee $LOGFILE
cd cp0
ls
trace maxData > 10 : 8 0 : maxData : interactive
run
printTrace 0
unwatch 0
trace maxData > 11 : 8 0 : maxData : printTrace
run 1us
unwatch 1
trace maxData > 12 : 8 0 : maxData : printStatus
run 1us
unwatch 2
ls
trace maxData > 13 : 8 0 : minData : set minData 10
run 1us
print minData
trace maxData > 14 : 8 0 : maxData : shutdown
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
PSTR="Entering interactive mode at time 1000"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="> TriggerRecord:@cycle1000: samples lost = 0: cp0/maxData=100"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# printTrace
PSTR="TriggerRecord:@cycle68000: samples lost = 0: cp0/maxData=100"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# printStatus
PSTR="to be delivered at time: 1100000"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

#set
PSTR="> minData = 10"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# shutdown
PSTR="Trigger action shutting down simulation"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Simulation Complete
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
  rm -f $LOGFILE $OUTFILE $CMDFILE
fi

wait
echo "PASS"
exit $retVal
