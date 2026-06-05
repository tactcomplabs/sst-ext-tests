#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check trace with set action for more types - particularly elements"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Settings
CLEANUP=1
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="dbgsst15.py"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

cat << EOF > $CMDFILE
# Note: When using container elements that are indices, only the changed 
# trigger condition is valid. When using a comparison op (e.g. ==, <, ...)
# it tries to interpret the element index as a number instead of a variable.
# e.g. trace 0 == 5 interprets this as const 0 == const 5 which is always false

cd cp0
cd v_ag_class
ls -l
# Trace changed - valid
# CHECK 0 trace 0 changed : 8 0 : 0 1 : set 1 blue\nAdded watchpoint #0
trace 0 changed : 8 0 : 0 1 : set 1 blue

run 10us

# CHECK 1 ls -l\n0 = 47 \(.+\n1 = "blue"
ls -l

# CHECK 2 printTrace 0\nTriggerCount=0\nbuf\[0\] BC @9996000 \(-\) 0 = 47 1 = "blue"
printTrace 0

unwatch 0

# Trace - invalid action to assign string to int
# CHECK 3 trace 0 changed : 8 0 : 0 1 : set 0 red\nInvalid type for value: red
trace 0 changed : 8 0 : 0 1 : set 0 red
ls -l

cd ..
cd v_ag_struct
ls -l
# Trace changed - valid
# CHECK 4 trace 1 changed : 8 0 : 0 1 : set 0 8\nAdded watchpoint #1
trace 1 changed : 8 0 : 0 1 : set 0 8

run 10us

# CHECK 5 ls -l\n0 = 8 \(.+\n1 = "184"
ls -l

# Note trigger count is 0 because buffer is reset when action invoked
# CHECK 6 printTrace 1\nTriggerCount=0\nbuf\[6\] BC @19996000 \(-\) 0 = 8 1 = "184"
printTrace 1

unwatch 1

# Trace - invalid action to assign decimal to int
# CHECK 7 trace 1 changed : 8 0 : 0 1 : set 0 1.75\nInvalid type for value: 1.75
trace 1 changed : 8 0 : 0 1 : set 0 1.75
ls -l

cd ..
cd v_pair_u64_str
ls -l

# Trace changed - valid
# CHECK 8 trace first changed : 8 0 : first second : set second orange\nAdded watchpoint #2
trace first changed : 8 0 : first second : set second orange

run 10us

# CHECK 9 ls -l\nfirst = 295 \(.+\nsecond = "orange"
ls -l

# CHECK 10 printTrace 2\nTriggerCount=0\nbuf\[6\] BC @29996000 \(-\) first = 295 second = "orange"
printTrace 2

unwatch 2

# Trace - invalid action to assign string to int
# CHECK 11 trace first changed : 8 0 : first second : set first white\nInvalid type for value: white
trace first changed : 8 0 : first second : set first white

cd ..
p v_char

# Trace v_char - valid
# CHECK 12 trace v_char == 1 : 8 2 : v_char : set v_char 100\nAdded watchpoint #3
trace v_char == 1 : 8 2 : v_char : set v_char 100

run 1us

# CHECK 13 p v_char\nv_char = 100
p v_char

# CHECK 14 printTrace 3\nTriggerCount=0\nbuf\[5\] BC @30996000 \(-\) v_char = 100
printTrace 3

unwatch 3

# Trace - invalid action to assign string to char
# CHECK 15 trace v_char == 1 : 8 2 : v_char : set v_char 'a'\nInvalid type for value: 'a'
trace v_char == 1 : 8 2 : v_char : set v_char 'a'

# Container values can change - tracing not guaranteed
#cd v_queue_unsigned
#cd container

shutdown
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=16

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
retVal=0
$LAUNCH << EOF | tee $LOGFILE
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

# v_ag_class valid trace : blue
PSTR="LastTriggerRecord:@cycle1900000: SamplesLost=0: 0 = 43 1 = \"19\""
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="set cp0/v_ag_class/1 blue"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# v_ag_struct valid trace : 8
PSTR="LastTriggerRecord:@cycle11500000: SamplesLost=0: 0 = 47 1 = \"115\""
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="set cp0/v_ag_struct/0 8"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# v_pair_u64_str valid trace : orange
PSTR="LastTriggerRecord:@cycle20000000: SamplesLost=0: first = 200 second = \"S200\""
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

PSTR="set cp0/v_pair_u64_str/second orange"
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
