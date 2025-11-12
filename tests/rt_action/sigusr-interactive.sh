#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests sigusr1/2 with interactive console real time action"
#EXT_TEST TIMEOUT 90
#
# 0) Set up pipe
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -s SIGUSR<N> <PID>' to send the signal
# 4) run command in interactive consols
# 5) wait for completion
# 6) compare to expected results (offline?)
#set -m # enable job control

# Settings
SIG="sigusr1 sigusr2"
ACTION="sst.rt.interactive"
CLEANUP=1

# Set component options
OPTS=""
# Optional first argument for number of clocks
if [ $# -eq 1 ]; then
  OPTS+=" --clocks $1"
fi

# Sleep times for sst and bash
OPTS+=" --sleep 3"
BASH_SLEEP=2

# 0) Set up the pipe
pipe="/tmp/sigusr-interactive-DEV-$PPID"
#mkfifo $pipe
if [[ ! -p $pipe ]]; then
  echo "Creating pipe: $pipe"
  mkfifo $pipe
fi

for sig in $SIG; do
  for action in $ACTION; do

# 1) Launch the program in the background, running long enough to send signal
outfile="sigusr-interactive-DEV-$sig-$action-$PPID.out"
if [[ -f $outfile ]]; then
  rm $outfile
fi

LAUNCH="sst --interactive-console=sst.interactive.simpledebug --$sig=$action --add-lib-path=$SST_COMPONENT_BASE/core-debug rt_action.py -- $OPTS"
echo $LAUNCH
$LAUNCH < $pipe > $outfile &
exec 3>$pipe    # Opens pipe for writing

# 2) Get the PID
JOBS=($(jobs -l))
JSTR=${JOBS[0]}
PID=${JOBS[1]}
sleep $BASH_SLEEP

# 3) Send signal 
echo "kill -s $sig $PID" | tee $outfile
kill -s $sig $PID
retVal=$?
if [ $retVal -ne 0 ]; then
  echo ERROR with kill -s $sig $PID
  exit $retVal
fi

# 4) Send run command in interactive console
#fg $JID
echo run 1us > $pipe
echo run > $pipe

# 5) Wait for completion
wait
retVal=$?
exec 3>&- # close pipe
echo $sig=$action Complete

# 6) Check results
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action return code"
  rm $pipe
  exit $retVal
fi

grep "Interactive Console real time action" $outfile
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action grep"
  rm $pipe
  exit $retVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $outfile
fi

done  # for $action
done  # for $sigusr


rm $pipe


echo "PASS"
wait
exit $retVal
