#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise std::queue<unsigned>"
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

# CHECK 0 p v_queue_unsigned\nv_queue_unsigned \(
p v_queue_unsigned

cd v_queue_unsigned
# CHECK 1 ls\ncontainer/ \(
ls

# CHECK 2 p container\ncontainer .+\n 0 = 100 .+\n 1 = 200 .+\n 2 = 300
p container

cd container
# CHECK 3 ls\n0 = 100 .+\n1 = 200 .+\n2 = 300
ls

# CHECK 4 p 0\n0 = 100
p 0

# CHECK 5 p 1\n1 = 200
p 1

# CHECK 6 p 2\n2 = 300
p 2

set 0 1100
set 1 1200
set 2 1300
# CHECK 7 ls\n0 = 1100 .+\n1 = 1200 .+\n2 = 1300
ls

# advance simulator sufficiently to observe change in front data
run 10400ns

# confirm cp0 front value is changing
# DbgSST15[cp0:tickleBits:1300000]: v_queue_unsigned.front()=1200
# DbgSST15[cp0:tickleBits:2600000]: v_queue_unsigned.front()=1300
# DbgSST15[cp0:tickleBits:3900000]: v_queue_unsigned.front()=1101
# DbgSST15[cp0:tickleBits:5200000]: v_queue_unsigned.front()=1201
# DbgSST15[cp0:tickleBits:6500000]: v_queue_unsigned.front()=1301
# DbgSST15[cp0:tickleBits:7800000]: v_queue_unsigned.front()=1102
# DbgSST15[cp0:tickleBits:9100000]: v_queue_unsigned.front()=1202

# CHECK 8 pwd\ncp0/v_queue_unsigned/container \(
pwd

# CHECK 9 ls\n0 = 1202 \(.+\n1 = 1302 \(.+\n2 = 1103 \(
ls
# 0 = 1202 (unsigned int)
# 1 = 1302 (unsigned int)
# 2 = 1103 (unsigned int)

shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=10

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
