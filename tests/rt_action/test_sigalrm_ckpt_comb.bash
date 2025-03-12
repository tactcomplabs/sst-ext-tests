#!/bin/bash

# Test sigalrm real time with multiple actions
# 
# 0) set pass string 
# 1) launch the program
# 2) wait for completion
# 3) check result


# Settings
SIG="sigalrm"
ACTION="sst.rt.checkpoint"
ACTION2="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat" # sst.rt.checkpoint"
CONFIG="test_Checkpoint.py"

if [[ -f test.*.out ]]; then
  rm test.*.out
fi

for sig in $SIG; do
  for action in $ACTION; do
    for action2 in $ACTION2; do

PSTR="Simulation Checkpoint"

#0 Get pass criterion
if [[ $action2 == "sst.rt.exit.clean" ]]; then
#echo clean
PSTR2="EXIT-AFTER TIME"
elif [[ $action2 == "sst.rt.exit.emergency" ]]; then
#echo emergency
PSTR2="EMERGENCY"
elif [[ $action2 == "sst.rt.status.core" ]]; then
#echo status.core
PSTR2="CurrentSimCycle"
elif [[ $action2 == "sst.rt.status.all" ]]; then
#echo status.all
PSTR2="TimeVortex state"
elif [[ $action2 == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR2="Heartbeat"
elif [[ $action2 == "sst.rt.checkpoint" ]]; then
#echo checkpoint
PSTR2="Simulation Checkpoint"
fi

# 1) Launch the program in the background, running long enough to send signal
LAUNCH="sst --$sig='$action(interval=1s);$action2(interval=2s)' $CONFIG"
echo $LAUNCH

#exit

eval $LAUNCH > test.$sig.$action.$action2.out 2>&1 

# 2) wait for completion 
wait

echo $sig=$action $action2 Complete

# 3) Check result
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action $action2 return code"
  exit $retVal
fi

grep "$PSTR" ./test.$sig.$action.$action2.out > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action grep"
  exit $grepVal
fi

grep "$PSTR2" ./test.$sig.$action.$action2.out > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action2 grep"
  exit $grepVal
fi

echo

done  # for $action2
done  # for $action
done  # for $sig

echo "PASS"
exit $retVal






