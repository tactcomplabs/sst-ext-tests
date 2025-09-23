#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Check for interactive, printTrace, printStatus, and set actions"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="dbgsst15.py"
PSTR="^Entering interactive mode at time 140000000"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH 2>&1 << EOF | tee $LOGFILE || exit 1
cd cp0
ls
trace maxData > 10 : 8 0 : maxData : interactive
run
printTrace 0
unwatch 0
trace maxData > 11 : 8 0 : maxData : printTrace
run 1us
unwatch 0
trace maxData > 12 : 8 0 : maxData : printStatus
run 1us
unwatch 0
ls
trace maxData > 13 : 8 0 : minData : set minData 10
run 1us
ls
shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

#grep "$PSTR" $LOGFILE > /dev/null
diff $LOGFILE $CHKFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR in diff $LOGFILE $CHKFILE"
  exit $retVal
fi
echo "Log file matches check file"

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE
fi

wait
echo "PASS"
exit $retVal
