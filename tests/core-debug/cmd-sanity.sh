#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Enter interactive mode, change an internal variable and confirm it has been change"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
TNAME=int-change-value
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"
LOGFILE=$TNAME.out

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s  $CONFIG"
echo $LAUNCH
$LAUNCH <<EOF | tee $LOGFILE || exit 1
ls
cd c7
ls
set test_string HelloMyNameIsC7AndICannotQuoteAString
print test_string
quit
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
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
  rm $LOGFILE
fi

wait
echo "PASS"
exit $retVal
