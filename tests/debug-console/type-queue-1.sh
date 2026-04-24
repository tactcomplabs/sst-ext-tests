#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise std::queue<unsigned> with one component"
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
CONFIG="omni.py"
CONFIG_OPTS="--function0=dbgsst15.OMQueue --verbose=0"

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

cd c0
cd c0:function0/
cd v_queue_unsigned_/
cd container/
# CHECK 0 pwd\n/c0/c0:function0/v_queue_unsigned_/container
pwd

# CHECK 1 ls -ll\n0 = 100 \(.+\n1 = 200 \(.+\n2 = 300 \(
ls -ll
# 0 = 100 (unsigned int)
# 1 = 200 (unsigned int)
# 2 = 300 (unsigned int)
run 10ns
# 1000: v_queue_unsigned_.front()=200
# 2000: v_queue_unsigned_.front()=300
# 3000: v_queue_unsigned_.front()=101
# 4000: v_queue_unsigned_.front()=201
# 5000: v_queue_unsigned_.front()=301
# 6000: v_queue_unsigned_.front()=102
# 7000: v_queue_unsigned_.front()=202
# 8000: v_queue_unsigned_.front()=302
# 9000: v_queue_unsigned_.front()=103
# Entering interactive mode at time 10000 
# Ran clock for 10000 sim cycles

# CHECK 2 ls -ll\n0 = 103 \(.+\n1 = 203 \(.+\n2 = 303 \(
ls -ll
# 0 = 103 (unsigned int)
# 1 = 203 (unsigned int)
# 2 = 303 (unsigned int)

# sst-core #1517 refreshes object map on break into interactive mode.
# Solution for watchpoints is....?

# watch 0 changed
# run
# # check- 3 ls\n0 = 104 \(.+\n1 = 204 \(.+\n2 = 304 \(
# ls

# run
# # check- 4 ls\n0 = 105 \(.+\n1 = 205 \(.+\n2 = 305 \(
# ls

# unwatch 0
# watch 0 > 200
# # check- 5 ls\n0 = 201 \(.+\n1 = 301 \(.+\n2 = 401 \(
# ls

shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=3

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- $CONFIG_OPTS"
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
