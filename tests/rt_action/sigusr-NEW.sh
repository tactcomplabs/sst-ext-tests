#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TIMEOUT 120
#EXT_TEST TEST_FILE_DESC "Tests sigusr1/2 for single real time actions"
# 
# 0) set pass string 
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -s SIGUSR<N> <PID>' to send the signal
# 4) wait for completion
# 5) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
#set -uo pipefail  # Can't use -u with the sst component base check below

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Set component options
OPTS=""
# Optional first argument for number of clocks
if [ $# -eq 1 ]; then
  OPTS+=" --clocks $1"
fi

# Sleep times for sst and bash
OPTS+=" --sleep 3"
BASH_SLEEP=2

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
SIG="sigusr1 sigusr2"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG="rt_action.py"
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

OUTFILE=$TNAME.$sig.$action.out
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

# TODO directory creation fails when using a relative path
PREFIX="ckpt_${TNAME}_${sig}_$action"
# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 1) Launch the program in the background, running long enough to send signal
LAUNCH="sst --$sig=$action --checkpoint-prefix=${PREFIX} --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- $OPTS"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 &

# 2) Get the PID
JOBS=($(jobs -l))
PID=${JOBS[1]}
#echo $PID
sleep $BASH_SLEEP

# 3) Send signal 
echo ">>>>>>> kill -s $sig $PID" | tee $OUTFILE
kill -s $sig $PID

# 4) wait for completion 
wait
retVal=$?
echo $sig=$action Complete

# 5) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $sig=$action return code [$retVal]"
  exit $retVal
fi

grep "$PSTR" $OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $sig=$action missing grep [$PSTR]"
  exit $retVal
fi
echo
if [ $action == "sst.rt.checkpoint" ]; then
  if [[ ! -d $PREFIX ]]; then
    cat $OUTFILE
    echo "ERROR $sig=$action missing checkpoint dir: $PREFIX"
    exit 99
  fi
fi

# Cleanup output directories
if [ $CLEANUP == 1 ]; then
  rm $OUTFILE
  if [ $action == "sst.rt.checkpoint" ]; then
    # If checkpoint directory did not get created then fail ( not fool proof )
    rm -r $PREFIX* 
  fi
fi

done  # for $action
done  # for $sig

echo "PASS"
exit $retVal

