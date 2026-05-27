#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check for seg fault with recursive print"
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
confirm false
# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n
# recursive prints and run with space in time used to cause a seg fault
# CHECK 0 print\nInvalid format
print
# CHECK 1 print -r\nInvalid format
print -r
# CHECK 2 print -r cp0\nInvalid number format
print -r cp0
# CHECK 3 print -r3 cp0\nInvalid number format
print -r3 cp0
# CHECK 4 print -v\nInvalid format
print -v
# CHECK 5 print -v cp0\nInvalid number format
print -v cp0
# CHECK 6 print -v3 cp0\nInvalid format
print -v3 cp0
# CHECK 7 print cp0\n
print cp0
# CHECK 8 print -r 1 cp0\ncp0\/\ncliType = 0\nclockDelay = 100
print -r 1 cp0
# CHECK 9 print -r 1 -f hex cp0\ncp0\/\ncliType = 0\nclockDelay = 0x64
print -r 1 -f hex cp0
# CHECK 10 print -r 1 -f oct cp0\ncp0\/\ncliType = 0\nclockDelay = 0144
print -r 1 -f oct cp0
# CHECK 11 print -r 1 -v 1 -f dec cp0\ncp0\/\ncliType = 0 \(.+)\nclockDelay = 100 \(.+)
print -r 1 -v 1 -f dec cp0

run 1000ps
run 1000 ps
shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=12

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
echo $LAUNCH
revVal=0
$LAUNCH << EOF  | tee $LOGFILE
replay $CMDFILE
confirm false
exit
EOF

RC=$?

echo $TNAME Complete

# Check result
if [ $RC -ne 0 ]; then
  echo "ERROR $TNAME returned $RC"
  exit $RC
fi

# spot checks
# First argument is the number of expected checks
${SPOTCHECKS} $NUMCHECKS $LOGFILE

RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: Test Failed with RC=$RC"
  exit $RC
fi

# shutdown
PSTR="Simulation is complete, simulated time: 0 s"
grep "$PSTR" $LOGFILE > /dev/null
RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $RC
fi
echo "Found pass string \"$PSTR\""

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
