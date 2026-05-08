#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Tests sigalrm for single real time actions"
#EXT_TEST TIMEOUT 240
# 
# 0) set pass string 
# 1) launch the program in the background
# 2) wait for completion
# 3) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
SIG="sigalrm"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
CLEANUP=1

for sig in $SIG; do
  for action in $ACTION; do

#0 Get pass criterion, PREFIX, and OUTFILE
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

PREFIX="ckpt_${TNAME}_${sig}_$action"
OUTFILE="$TNAME.$action.out"

# 1) Launch the program
# Remove stale out file and checkpoint dir if needed
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

LAUNCH="sst --$sig=$action(interval=1s) --checkpoint-prefix=$PREFIX $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 

# 2) wait for completion 
retVal=$?
echo $sig=$action Complete retVal $retVal

# 3) Check result
if [ $retVal -ne 0 ]; then
  #cat $OUTFILE
  echo "ERROR $sig=$action return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  #cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR"
  exit $retVal
fi
echo

# Check that checkpoint directory exists
if [[ $action == "sst.rt.checkpoint" ]]; then
  if [[ ! -d "$PREFIX" ]]; then
    #cat $OUTFILE
    echo "ERROR checkpoint directory '$PREFIX' not found"
    exit 255
  fi
fi

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  if [[ $action == "sst.rt.checkpoint" ]]; then
    rm -r $PREFIX
  fi
fi

done  # for $action
done  # for $sig

echo "PASS"
exit $retVal
