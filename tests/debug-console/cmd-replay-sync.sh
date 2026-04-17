#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Conditional watch trigger replayed from file"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint_4ms.py"
PSTR="Entering interactive mode at time 140000000"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
confirm false
ls
cd c7
watch duty_cycle_count == 1
run
# See PSTR for expected time to break into interactive mode
# Triggers should be disabled on quit or test will hang
quit
EOF

# Launch the program to start interactive mode at time 0
LAUNCH="sst --replay-file=$CMDFILE --interactive-console=sst.interactive.debugger --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH | grep -v 'talking' | tee $LOGFILE
retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

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
exit $retVal








