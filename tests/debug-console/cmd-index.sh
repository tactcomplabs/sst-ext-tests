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
# \n0 = 10\n1 = 20\n2 = 30\n3 = 40\n4 = 50.+
cd c0
# CHECK 0 p -v 1 function.+\n0 = 10 \(.+
p -v 1 function0[0]

set function0[0] 11

# CHECK 1 p -v 1 function.+\n0 = 11 \(.+
p -v 1 function0[0]
run 1us

# CHECK 2 p -v 1 function.+\n0 = 11 \(.+
p -v 1 function0[0]
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
