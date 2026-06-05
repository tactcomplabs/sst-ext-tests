#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Minimal smoke test using local test_cpt component"
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
CONFIG="test_cpt.py"

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
# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n
# There must be an empty line before '# CHECK'

# CHECK 0 ls\nc0\/
ls

# CHECK 1 cd c0\n
cd c0

# CHECK 2 ls\nclock_handler\/
ls

confirm false
quit
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=3

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

# Simulation Complete
PSTR="^Simulation is complete, simulated time: 4.007 ms$"
egrep "$PSTR" $LOGFILE > /dev/null
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
