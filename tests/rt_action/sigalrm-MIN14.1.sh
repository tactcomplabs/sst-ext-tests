#!/bin/bash
#EXT_TEST TEST_FILE_PARAM MIN14.1
#EXT_TEST TEST_FILE_DESC "Tests sigalrm for single real time actions"
# 
# 0) set pass string 
# 1) launch the program in the background
# 2) wait for completion
# 3) check result


# Settings
SIG="sigalrm"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"

for sig in $SIG; do
  for action in $ACTION; do

#0 Get pass criterion
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
PSTR="TimeVortex state"
elif [[ $action == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR="Heartbeat"
elif [[ $action == "sst.rt.checkpoint" ]]; then
#echo checkpoint
PSTR="Simulation Checkpoint"
fi

# 1) Launch the program
if [[ -f test.$sig.$action.out ]]; then
  rm test.$sig.$action.out
fi

LAUNCH="sst --$sig='$action(interval=1s)' $CONFIG"
echo $LAUNCH

eval $LAUNCH > test.$sig.$action.out 2>&1 

# 2) wait for completion 
wait
retVal=$?
echo $sig=$action Complete

# 3) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action return code"
  exit $retVal
fi

grep "$PSTR" ./test.$sig.$action.out > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action grep"
  exit $grepVal
fi
echo

# Cleanup output directories
rm test.$sig.$action.out

done  # for $action
done  # for $sig

echo "PASS"
exit $retVal






