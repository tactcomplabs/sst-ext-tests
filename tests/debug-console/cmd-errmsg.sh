#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Verify error handling for trace related commands"
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
CONFIG=$(realpath dbgsst15.py)

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

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
confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

cd cp0

# --- trace

# CHECK 0 trace v changed : 4 4 : v_ll : interactive\nUnknown Constant in expression
trace v changed : 4 4 : v_ll : interactive

# CHECK 1 trace v_ll = 5 : 4 4 : v_ll : interactive\nUnknown comparison operation specified in trigger test
trace v_ll = 5 : 4 4 : v_ll : interactive

# CHECK 2 trace v_ll changed : g 4 : v_ll : interactive\nInvalid argument for buffer size: g
trace v_ll changed : g 4 : v_ll : interactive

# Currently prints colon instead of bad arg
# CHECK 3 trace v_ll changed : 4 g : v_ll : interactive\nInvalid argument for post trigger delay: g
trace v_ll changed : 4 g : v_ll : interactive

# CHECK 4 trace v_ll changed : 4 4 : v : interactive\nUnknown variable: v
trace v_ll changed : 4 4 : v : interactive

# CHECK 5 trace v_ll changed : 4 4 : v_ll : hello\nError in action: hello
trace v_ll changed : 4 4 : v_ll : hello

# CHECK 6 trace v_ll changed : 4 4 : v_ll : interactive\nAdded watchpoint #0
trace v_ll changed : 4 4 : v_ll : interactive

# CHECK 7 trace v_ull changed : 4 4 : v_ll : interactive\nAdded watchpoint #1
trace v_ull changed : 4 4 : v_ll : interactive

# CHECK 8 trace v_int changed : 4 4 : v_ll : interactive\nAdded watchpoint #2
trace v_int changed : 4 4 : v_ll : interactive

# --- unwatch

# CHECK 9 trace v_uint changed : 4 4 : v_ll : interactive\nAdded watchpoint #3
trace v_uint changed : 4 4 : v_ll : interactive

# CHECK 10 unwatch foo\nInvalid index format specified.
unwatch foo

# CHECK 11 unwatch 10\nWatch point 10 not found. 
unwatch 10

unwatch 3

# --- printWatchpoint

# CHECK 12 printwatchpoint 0\nWP0: TriggerCount 0 : ALL : /cp0/v_ll CHANGED  : bufsize = 4 postDelay = 4 : v_ll  : interactive
printwatchpoint 0

# CHECK 13 printwatchpoint hello\nInvalid watchpoint index: hello
printwatchpoint hello

# CHECK 14 printwatchpoint 10\nInvalid watchpoint index: 10
printwatchpoint 10

# CHECK 15 printwatchpoint 3\nInvalid watchpoint index: 3
printwatchpoint 3

# --- setHandler

# CHECK 16 setHandler 0 ac\nWP 0 - /cp0/v_ll CHANGED
setHandler 0 ac

# CHECK 17 setHandler hello ac\nInvalid watchpoint index: hello
setHandler hello ac

# CHECK 18 setHandler 10 ac\nInvalid watchpoint index: 10
setHandler 10 ac

# CHECK 19 setHandler 3 ac\nInvalid watchpoint index: 3
setHandler 3 ac

# CHECK 20 setHandler 2 hello\nInvalid handler type: hello
setHandler 2 hello

# --- addTraceVar

# CHECK 21 addTraceVar 0 v_ull\nWP 0 - /cp0/v_ll CHANGED
addTraceVar 0 v_ull

# CHECK 22 addTraceVar hello v_ull\nInvalid watchpoint index: hello
addTraceVar hello v_ull

# CHECK 23 addTraceVar 10 v_ull\nInvalid watchpoint index: 10
addTraceVar 10 v_ull

# CHECK 24 addTraceVar 3 v_ull\nInvalid watchpoint index: 3
addTraceVar 3 v_ull

# CHECK 25 addTraceVar 2 hello\nUnknown variable: hello
addTraceVar 2 hello

# --- printTrace

run 10us

# CHECK 26 printTrace 0\nTriggerCount=0\nbuf\[3\] AC @9996000 \(-\) v_ll = -5 v_ull = 5
printTrace 0

# CHECK 27 printTrace hello\nInvalid watchpoint index: hello
printTrace hello

# CHECK 28 printTrace 10\nInvalid watchpoint index: 10
printTrace 10

# CHECK 29 printTrace 3\nInvalid watchpoint index: 3
printTrace 3

# --- resetTrace

resetTrace 0
# CHECK 30 printtrace 0\nNo trace samples in current buffer
printtrace 0

# CHECK 31 resetTrace hello\nInvalid watchpoint index: hello
resetTrace hello

# CHECK 32 resetTrace 10\nInvalid watchpoint index: 10
resetTrace 10

# CHECK 33 resetTrace 3\nInvalid watchpoint index: 3
resetTrace 3

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=34

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
echo $LAUNCH
revVal=0
$LAUNCH << EOF  | tee $LOGFILE
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

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
