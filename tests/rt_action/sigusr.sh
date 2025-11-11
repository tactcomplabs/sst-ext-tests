#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests sigusr1/2 for single real time actions"
# 
# 0) set pass string 
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -s SIGUSR<N> <PID>' to send the signal
# 4) wait for completion
# 5) check result

# Set component options
OPTS="--sleep 3"
# Optional first argument for number of clocks
if [ $# -eq 1 ]; then
  OPTS+=" --clocks $1"
fi

# Sleep time for bash
BASH_SLEEP=2

# Settings
SIG="sigusr1 sigusr2"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG="rt_action.py" #"test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt_sigusr"
CLEANUP=1

for sig in $SIG; do
  for action in $ACTION; do

# 0) Get pass criterion
if [[ $action == "sst.rt.exit.clean" ]]; then
#echo clean
PSTR="EXIT-AFTER TIME"
elif [[ $action == "sst.rt.exit.emergency" ]]; then
#echo emergency
PSTR="EMERGENCY"
elif [[ $action == "sst.rt.status.core" ]]; then
#echo status.core
PSTR="CurrentSimCycle"
elif [[ $action == "sst.rt.status.all" ]]; then
#echo status.all
PSTR="Components:"
elif [[ $action == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR="Heartbeat"
elif [[ $action == "sst.rt.checkpoint" ]]; then
#echo checkpoint
PSTR="Simulation Checkpoint"
fi

# 1) Launch the program in the background, running long enough to send signal
#if [[ -f test.$sig.$action.out ]]; then
#  rm test.$sig.$action.out
#fi

LAUNCH="sst --$sig=$action --checkpoint-prefix=$PREFIX $CONFIG -- $OPTS"
echo $LAUNCH

$LAUNCH | tee test.$sig.$action.out 2>&1 &

# 2) Get the PID
JOBS=($(jobs -l))
PID=${JOBS[1]}
#echo $PID
sleep $BASH_SLEEP

# 3) Send signal 
kill -s $sig $PID

# 4) wait for completion 
wait
retVal=$?
echo $sig=$action Complete

# 5) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action return code [$retVal]"
  exit $retVal
fi

grep "$PSTR" ./test.$sig.$action.out > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action missing grep [$PSTR]"
  exit $retVal
fi
echo

# Cleanup output directories
if [ $CLEANUP == 1 ]; then
  rm test.$sig.$action.out
  if [ $action == "sst.rt.checkpoint" ]; then
    rm -r $PREFIX*
  fi
fi

done  # for $action
done  # for $sig

echo "PASS"
exit $retVal

