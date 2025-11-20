#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Log history to file and check it"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="../rt_action/test_Checkpoint.py"
PSTR="0 10000000 15000000 20000000 23000000 30000000 31000000 39000000 40000000 47000000 50000000 "

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s $CONFIG"
echo $LAUNCH
$LAUNCH << EOF | tee $LOGFILE || exit
logging $OUTFILE
ls
cd c7
watch duty_cycle_count changed
run
!!:p
!!
h
!-2
!-3
h
!5
!?un
!r
pwd
pwd
run
!-1
pwd
!-3
h
shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

check=$(awk '/interactive mode at time/ {printf("%s ", $NF)}' $LOGFILE)
echo "Checking for match:"
echo "\"$PSTR\" (expected)"
echo "\"$check\" (acquired)"
if [[ "$check" == "$PSTR" ]]; then
  echo "Found match"
else
  echo "ERROR mismatch"
  exit 1
fi

# extra check of console logging to make sure command substitution occured.
cat << EOF > $CHKFILE
ls
cd c7
watch duty_cycle_count changed
run
run
run
h
run
run
h
run
run
run
pwd
pwd
run
run
pwd
run
h
shutdown
EOF

echo "diff $CHKFILE $OUTFILE"
diff $CHKFILE $OUTFILE
if [ $? -ne 0 ]; then
  echo "ERROR: console log mismatch"
  exit 1
fi

# One more sanity check for printing history
h_check="10 h 11 run 12 run 13 run 14 pwd 15 pwd 16 run 17 run 18 pwd 19 run "
h_actual=$(egrep '^[0-9]+ [a-z]+$'  $LOGFILE | tail -10 | tr '\n' ' ')
echo "checking history string"
echo "expect: $h_check"
echo "actual: $h_actual"
if [ "$h_check" != "$h_actual" ]; then
  echo "ERROR: history check failed"
  exit 2
fi

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
