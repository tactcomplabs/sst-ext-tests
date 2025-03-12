#!/bin/bash

# Test sigusr1/2 real with interactive console real time actions
#
# 0) Set up pipe
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -SIGUSR<N> <PID>' to send the signal
# 4) run command in interactive consols
# 5) wait for completion
# 6) compare to expected results (offline?)
#set -m # enable job control

# Settings
SIGUSR="sigusr1 sigusr2"
ACTION="sst.rt.interactive"

# 0) Set up the pipe
pipe=/tmp/testpipe
#mkfifo $pipe
if [[ ! -p $pipe ]]; then
  echo "Creating pipe: $pipe"
  mkfifo $pipe
fi

for sigusr in $SIGUSR; do
  for action in $ACTION; do

# 1) Launch the program in the background, running long enough to send signal
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --$sigusr=$action test_MessageMesh.py"
echo $LAUNCH
$LAUNCH < $pipe > test.$action.out &
exec 3>$pipe    # Opens pipe for writing

# 2) Get the PID
JOBS=($(jobs -l))
JSTR=${JOBS[0]}
PID=${JOBS[1]}
sleep 2

# 3) Send signal 
kill -$sigusr $PID

# 4) Send run command in interactive console
#fg $JID
echo run 1us > $pipe
echo run > $pipe

# 5) Wait for completion
wait
exec 3>&- # close pipe
echo $sigusr=$action Complete

# 6) Check results
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sigusr=$action return code"
  exit $retVal
fi

grep "real time action" ./test.$action.out;
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sigusr=$action grep"
  exit $grepVal
fi
echo

done  # for $action
done  # for $sigusr

echo "PASS"
exit $retVal







