#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Tests sigusr1/2 with default interactive console w/checkpoint"
#EXT_TEST TIMEOUT 90
#
# 0) Set up PIPE
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -s SIGUSR<N> <PID>' to send the signal
# 4) run command in interactive consols
# 5) wait for completion
# 6) compare to expected results (offline?)
#set -m # enable job control

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint.py"
PSTR=""

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
CKPTPREFIX=ckpt_$TNAME
PIPE="/tmp/${TNAME}-${PPID}.pipe"

SIG="sigusr1 sigusr2"
ACTION="sst.rt.interactive"

# 0) Set up the PIPE
#mkfifo $PIPE
if [[ ! -p $PIPE ]]; then
  echo "Creating PIPE: $PIPE"
  mkfifo $PIPE
fi

for sig in $SIG; do
  for action in $ACTION; do

  # 1) Launch the program in the background, running long enough to send signal
  LOGFILE=$TNAME.$sig.$action.log
  if [[ -f $LOGFILE ]]; then
    rm $LOGFILE
  fi

  LAUNCH="sst --$sig=$action --checkpoint-enable --checkpoint-prefix=$CKPTPREFIX test_Checkpoint.py"
  echo $LAUNCH
  $LAUNCH < $PIPE > $LOGFILE &
  exec 3>$PIPE    # Opens PIPE for writing

  # 2) Get the PID
  JOBS=($(jobs -l))
  JSTR=${JOBS[0]}
  PID=${JOBS[1]}
  sleep 2

  # 3) Send signal 
  kill -s $sig $PID
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo ERROR sending signal: kill -s $sig $PID
    exit $retVal
  fi

  # 4) Send run command in interactive console
  #fg $JID
  echo cd c0 > $PIPE
  echo cd xorshift > $PIPE
  echo trace w changed : 32 4 : w x y z : checkpoint > $PIPE
  echo setHandler 0 ae ac > $PIPE
  echo printWatchpoint 0 > $PIPE
  echo run 400us > $PIPE
  echo shutdown > $PIPE

  # 5) Wait for completion
  wait
  retVal=$?
  exec 3>&- # close PIPE
  wait
  echo $TNAME $sig=$action Complete

  # 6) Check results
  if [ $retVal -ne 0 ]; then
    echo "ERROR $sig=$action returned $retVal"
    rm $PIPE
    exit $retVal
  fi

  PSTR="Interactive Console real time action"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    rm $PIPE
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\""

  PSTR="Simulation Checkpoint"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    rm $PIPE
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\""

  PSTR="Simulation is complete"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    rm $PIPE
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\""


  echo

  # Cleanup output directories
  if [ $CLEANUP -eq 1 ]; then
    rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
    rm -rf $CKPTPREFIX
  fi

  #rm $PIPE

done  # for $action
done  # for $sigusr

rm $PIPE
echo "PASS"
wait
exit $retVal
