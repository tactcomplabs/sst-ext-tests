#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Enter interactive mode and log commands to an external file"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
logging $OUTFILE
ls
cd c7
ls
set test_string HelloMyNameIsC7AndICannotQuoteAString
print test_string
quit
EOF

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH < $CMDFILE > $LOGFILE || exit 1

wait
retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
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

echo "PASS"
exit $retVal






