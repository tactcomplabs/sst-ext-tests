#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Enter interactive mode and replay session from an external file provided by SST command line option. Check comments have now effect"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
TNAME=cmd-replay-DEV
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
# comments and leading whitespace should have no effect if commented out
# shutdown
#shutdown 
   #    shutdown shutdown shutdown
# Also do some random white spaces
  ls
      cd         c7


ls

		
set test_string HelloMyNameIsC7AndICannotQuoteAString
print test_string
        quit
EOF

# Launch the program to start interactive mode at time 0
LAUNCH="sst --replay-file=$CMDFILE --interactive-console=sst.interactive.simpledebug --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH << EOF | tee $LOGFILE || exit 1
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






