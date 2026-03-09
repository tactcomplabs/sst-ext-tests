#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Verify comfirm set across threads"
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

RANKS=1
THREADS=2

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

# Launch the program to start interactive mode at time 0
LAUNCH="sst -n $THREADS --interactive-start --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
echo $LAUNCH
revVal=0
$LAUNCH << EOF  | tee $LOGFILE
thread 1
confirm false
thread 0
exit
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# Verify no prompt
PSTR="Do you want to delete all watchpoints"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR found unexpected string in $LOGFILE \"$PSTR\""
  exit $retVal
fi

# Simulation Complete
PSTR="Simulation is complete, simulated time: 1 ms"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
