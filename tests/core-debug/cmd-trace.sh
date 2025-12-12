#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Check for trace commands: trace, printWatchpoint, addTraceVar, printTrace, resetTrace, unwatch, quit"
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
PSTR="^Entering interactive mode at time 140000000"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH << EOF  | tee $LOGFILE
cd cp0
trace size > 50 : 32 4 : size : interactive
printWatchpoint 0
addTraceVar 0 rCheck
printWatchpoint 0
run
printTrace 0
resetTrace 0
printTrace 0
unwatch 0
trace size changed : 10 2 : size rCheck : interactive
printWatchpoint 1
run
prt 1
rst 1
prt 1
uw 1
trace minData < size : 8 0 : size : interactive
printWatchpoint 2
add 2 maxData
printWatchpoint 2
run 
printTrace 2
unwatch 2
trace size changed && maxData > 90 || minData < maxData || rCheck changed : 4 2 : rCheck size minData maxData : interactive
printWatchpoint 3
run
printTrace 3
quit
yes
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

#trace size > 50, printWatchpoint
PSTR="WP0: TriggerCount 0 : ALL : cp0/size > 50  : bufsize = 32 postDelay = 4 : cp0/size  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# addTraceVar, printWatchpoint
PSTR="WP0: TriggerCount 0 : ALL : cp0/size > 50  : bufsize = 32 postDelay = 4 : cp0/size cp0/rCheck  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# run, printTrace
PSTR="LastTriggerRecord:@cycle202000: SamplesLost=0: cp0/size=100 cp0/rCheck=1"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# resetTrace, printTrace 
PSTR="No trace samples in current buffer"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# trace size changed, printWatchpoint 
PSTR="WP1: TriggerCount 0 : ALL : cp0/size CHANGED  : bufsize = 10 postDelay = 2 : cp0/size cp0/rCheck  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# run, printTrace
PSTR="LastTriggerRecord:@cycle300000: SamplesLost=0: cp0/size=53 cp0/rCheck=-46"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# trace minData < size, printWP
PSTR="WP2: TriggerCount 0 : ALL : cp0/minData < cp0/size  : bufsize = 8 postDelay = 0 : cp0/size  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# add, printWatchpoint
PSTR="WP2: TriggerCount 0 : ALL : cp0/minData < cp0/size  : bufsize = 8 postDelay = 0 : cp0/size cp0/maxData  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# run, printTrace 0
PSTR="LastTriggerRecord:@cycle302000: SamplesLost=0: cp0/size=53 cp0/maxData=100"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# trace size changed && maxData > 90, printWatchpoint
PSTR="WP3: TriggerCount 0 : ALL : cp0/size CHANGED cp0/maxData > 90 cp0/minData < cp0/maxData cp0/rCheck CHANGED  : bufsize = 4 postDelay = 2 : cp0/rCheck cp0/size cp0/minData cp0/maxData  : interactive"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# run, printTrace 0
PSTR="LastTriggerRecord:@cycle304000: SamplesLost=0: cp0/rCheck=-46 cp0/size=53 cp0/minData=1 cp0/maxData=100"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# quit
PSTR="Removing all watchpoints and exiting ObjectExplorer"
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
