#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Check setHandler commands with trace"
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
run 2us
trace size changed : 16 14 : size : interactive
printWatchpoint 0
run
printTrace 0
sethandler 0 ac ae
printWatchpoint 0
run
printTrace 0
setHandler 0 bc be
printWatchpoint 0
run
printTrace 0
setHandler 0 ae
printWatchpoint 0
run
printTrace 0
setHandler 0 all
printWatchpoint 0
run
printTrace 0
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
