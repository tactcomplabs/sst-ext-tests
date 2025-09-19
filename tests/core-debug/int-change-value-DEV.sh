#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Enter interactive mode, change an internal variable and confirm it has been change"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
TNAME=int-change-value
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"
OUTFILE=$TNAME.out
CLEANUP=1

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s  $CONFIG"

echo $LAUNCH
$LAUNCH <<EOF | tee $OUTFILE
ls
cd c7
ls
set test_string HelloMyNameIsC7AndICannotQuoteAString
print test_string
quit
EOF

wait
retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

grep "$PSTR" $OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $OUTFILE \"$PSTR\""
  exit $retVal
fi

echo "Found pass string \"$PSTR\""
# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

echo "PASS"
exit $retVal






