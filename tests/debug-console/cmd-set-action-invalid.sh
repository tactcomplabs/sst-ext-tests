#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check set action error checking for invalid value"
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
CONFIG="test_Checkpoint_4ms.py"
PSTR=""

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH 2>&1 << EOF | tee $LOGFILE
cd c0
cd output
ls -l
# Valid set value
trace m_verboseLevel == 2 : 8 0 : m_verboseLevel m_verboseMask : set m_verboseMask 10
wl
printWatchpoint 0
run 10us
ls -l
wl
printTrace 0
unwatch 0
# 1 Invalid set value type - string instead of int
trace m_verboseLevel == 2 : 8 0 : m_verboseLevel m_verboseMask : set m_verboseMask hello
ls -l
wl
run 10us
# 2 Value is another variable - string instead of int
trace m_verboseLevel == 2 : 8 0 : m_verboseLevel m_verboseMask : set m_verboseMask m_verboseLevel
ls -l
wl
run 10us
ls -l
# 3 Invalid set value type - decimal instead of int
trace m_verboseLevel == 2 : 8 0 : m_verboseLevel m_verboseMask : set m_verboseMask 1.5
ls -l
wl
run 10us
ls -l
# 4 Invalid set value type - number instead of bool
trace m_objInitialized == 0 : 8 0 : m_objInitialized : set m_objInitialized 2
ls -l
wl
run 10us
ls -l
# 5 Invalid set value type - string instead of bool
trace m_objInitialized == 0 : 8 0 : m_objInitialized : set m_objInitialized hello
ls -l
wl
run 10us
ls -l
shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

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

# Valid trace will create trace and set var
PSTR="0: TriggerCount 1 : ALL : /c0/output/m_verboseLevel == 2  : bufsize = 8 postDelay = 0 : m_verboseLevel m_verboseMask  : set c0/output/m_verboseMask 10"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="m_verboseMask = 10 ("
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# 1 string -> int
PSTR="LastTriggerRecord:@cycle10000000: SamplesLost=0: m_verboseLevel = 2 m_verboseMask = 10"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR found fail string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="Invalid type for value: hello"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# 2 variable (str) -> int
PSTR="LastTriggerRecord:@cycle20000000: SamplesLost=0: m_verboseLevel = 2 m_verboseMask = 10"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR found fail string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="Invalid type for value: m_verboseLevel"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# 3 decimal -> int
PSTR="Invalid type for value: 1.5"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# 4 number -> bool
PSTR="Invalid type for value: 2"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# 5 string -> book
PSTR="Invalid type for value: hello"
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
