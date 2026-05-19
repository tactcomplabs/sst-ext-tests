#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Exercise arrays and tuples in 1 component with 2 slots"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Convenience environment variables
set +u
if [[ -z "${CLEANUP}" ]]; then
CLEANUP=1
fi
if [[ -z "${VERBOSE}" ]]; then
  VERBOSE=0
fi

set -u

# Common settings
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="omni.py"
CONFIG_OPTS="--function0=dbgsst15.OMArrays --function1=dbgsst15.OMQueue"

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
cd function0/
cd v_ping_t/
# CHECK 0 pwd\nc0/function0/v_ping_t \(unsigned short \[1000\]\)
pwd

# CHECK 1 p 0\n0 = 1 \(unsigned short\)
p 0

# CHECK 2 p 999\n999 = 1000 \(unsigned short\)
p 999

# CHECK 3 p 1000\nUnknown object in print command: 1000
p 1000

# CHECK 4 p -1\nUnknown object in print command: -1
p -1

run 8ns
# CHECK 5 p 42\n42 = 50 \(unsigned short\)
p 42

watch 42 changed
run 5ns

# CHECK 6 p 42\n42 = 51 \(
p 42

unwatch
watch 42 > 55
run 10ns
# CHECK 7 p 42\n42 = 55 \(
p 42

# now check pong which performs memcopy of ping.
cd ..
cd v_pong_t

# CHECK 8 pwd\nc0/function0/v_pong_t \(unsigned short \[1000\]\)
pwd
# CHECK 9 p 42\n42 = 54 \(
p 42

# TODO operator== appears to not be working. ( test all of them )
# unwatch
# watch 42 == 60
# run 20ns

shutdown

EOF

# IMPORTANT: Update this whenever adding checks in the command comments above
NUMCHECKS=10

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug --verbose=$VERBOSE $CONFIG -- $CONFIG_OPTS"
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
