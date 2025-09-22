#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Basic check that a simple conditional watch trigger occurs"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="TRIGGER DETECTED. PASS"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
ls
cd c7
watch duty_cycle_count == 1
run
# Entering interactive mode at time 140000000
# Watch point c7/duty_cycle_count buffer
$PSTR
# Triggers should be disabled on quit
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






