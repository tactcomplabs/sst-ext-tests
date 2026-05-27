#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise std::priority_queue<unsigned>"
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

# Extend the test time
cd cp1
ls
set clocks 1000000
cd ..
cd cp0
set clocks 1000000

# CHECK 0 p -v 1 v_priority_queue_unsigned\nv_priority_queue_unsigned \[1 elem
p -v 1 v_priority_queue_unsigned

cd v_priority_queue_unsigned
# CHECK 1 ls -l\ncontainer \[3 elem
ls -l

# CHECK 2 p -v 2 container\ncontainer .+\n0 = 3 .+\n1 = 2 .+\n2 = 1
p -v 2 container

cd container
# CHECK 3 ls -l\n0 = 3 .+\n1 = 2 .+\n2 = 1
ls -l

# CHECK 4 p 0\n0 = 3
p 0

# CHECK 5 p 1\n1 = 2
p 1

# CHECK 6 p 2\n2 = 1
p 2

set 0 1300
set 1 1200
set 2 1100
# CHECK 7 ls -ll\n0 = 1300 .+\n1 = 1200 .+\n2 = 1100
ls -ll

# advance simulator sufficiently to observe change in front data
run 10400ns

# Here we see only the original values changing
# 1300000: v_queue_unsigned.front()=200
# 1300000: v_queue_unsigned.front()=200
# 2600000: v_queue_unsigned.front()=300
# 2600000: v_queue_unsigned.front()=300
# 3900000: v_queue_unsigned.front()=101
# 3900000: v_queue_unsigned.front()=101
# 5200000: v_queue_unsigned.front()=201
# 5200000: v_queue_unsigned.front()=201
# 6500000: v_queue_unsigned.front()=301
# 6500000: v_queue_unsigned.front()=301
# 7800000: v_queue_unsigned.front()=102
# 7800000: v_queue_unsigned.front()=102
# 9100000: v_queue_unsigned.front()=202
# 9100000: v_queue_unsigned.front()=202

# CHECK 8 pwd\n/cp0/v_priority_queue_unsigned/container
pwd

# The values read do not match what is printed.
ls
# 0 = 1306 (unsigned int) <- this has changed!
# 1 = 1100 (unsigned int)
# 2 = 1200 (unsigned int)

#Tracing is not supported for these kinds of containers

shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=9

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
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
