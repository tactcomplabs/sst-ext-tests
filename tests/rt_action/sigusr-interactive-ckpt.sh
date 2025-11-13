#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
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
# TODO if this is an absolute path the checkpoint directory is incorrect.
CKPTPREFIX="ckpt_${TNAME}"
PIPE="/tmp/${TNAME}-${PPID}.pipe"

SIG="sigusr1 sigusr2"
ACTION="sst.rt.interactive"

# Set component options
OPTS=""
# Optional first argument for number of clocks
if [ $# -eq 1 ]; then
  OPTS+=" --clocks $1"
fi

# Sleep times for sst and bash
OPTS+=" --sleep 3"
BASH_SLEEP=2
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

  LAUNCH="sst --$sig=$action --checkpoint-enable --checkpoint-prefix=$CKPTPREFIX --add-lib-path=$SST_COMPONENT_BASE/core-debug rt_action.py -- $OPTS"
  echo $LAUNCH
  $LAUNCH < $PIPE > $LOGFILE &
  exec 3>$PIPE    # Opens PIPE for writing

  # 2) Get the PID
  JOBS=($(jobs -l))
  JSTR=${JOBS[0]}
  PID=${JOBS[1]}
  sleep $BASH_SLEEP

  # 3) Send signal 
  echo "kill -s $sig $PID" | tee $LOGFILE
  kill -s $sig $PID
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cat $LOGFILE
    echo ERROR sending signal: kill -s $sig $PID
    exit $retVal
  fi

  # 4) Send run command in interactive console
  #fg $JID
  echo cd cp0 > $PIPE
  echo ls > $PIPE
  echo trace curCycle == 0 : 32 4 : curCycle : checkpoint > $PIPE
  echo setHandler 0 ae ac > $PIPE
  echo printWatchpoint 0 > $PIPE
  echo run 1us > $PIPE
  echo shutdown > $PIPE

  # 5) Wait for completion
  wait
  retVal=$?
  exec 3>&- # close PIPE
  wait
  echo $TNAME $sig=$action Complete

  # 6) Check results
  if [ $retVal -ne 0 ]; then
    cat $LOGFILE
    echo "ERROR $sig=$action returned $retVal"
    rm $PIPE
    exit $retVal
  fi

  PSTR="Interactive Console real time action"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cat $LOGFILE
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    rm $PIPE
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\""

  PSTR="Simulation Checkpoint"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cat $LOGFILE
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    rm $PIPE
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\""

  PSTR="Simulation is complete"
  grep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cat $LOGFILE
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
