#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Log debug commands to an external file from multiple threads"
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
PSTR="teststring=HelloMyNameIsC2AndICannotQuoteAString"

RANKS=0
THREADS=4

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
logging $OUTFILE
ls
thread 3
cd c7
ls
thread 1
cd c2
ls
set test_string HelloMyNameIsC2AndICannotQuoteAString
print test_string
thread 2
continue 1us
confirm false
shutdown
EOF

# Launch the program to start interactive mode at time 0
LAUNCH="sst -n $THREADS --interactive-console=sst.interactive.debugger --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH < $CMDFILE | tee $LOGFILE

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# Should match except for the first 'logging' line
grep -v logging $CMDFILE > $CHKFILE
diff -q $CHKFILE $OUTFILE
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR console output does not match expected result"
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
