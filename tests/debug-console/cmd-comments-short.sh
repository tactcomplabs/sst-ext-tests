#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Check that comments have no effect in replay file"
#EXT_TEST TIMEOUT 30

# This test will enter interactive mode and replay session from an
# external file provided by SST command line option and checks
# that comments have no effect

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
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
# CMDFILE will be committed in repo. Not generated on the fly
CMDFILE=comments.in
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --replay-file=$CMDFILE --interactive-console=sst.interactive.debugger --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH << EOF  | tee $LOGFILE
shutd
EOF

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
  # rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
  rm -f $LOGFILE $OUTFILE  $CHKFILE
fi


wait
echo "PASS"
exit $retVal
