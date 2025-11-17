#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Tests sigusr1/2 expected fail when passing path to checkpoint-directory"
# 
# 0) set pass string 
# 1) launch the program in the background
# 2) 'jobs -l' to get the PID
# 3) 'kill -s SIGUSR<N> <PID>' to send the signal
# 4) wait for completion
# 5) check result

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
SIG="sigusr1 sigusr2"
ACTION="sst.rt.checkpoint"
CONFIG="rt_action.py" #"test_Checkpoint.py" #test_MessageMesh.py
CLEANUP=1

for sig in $SIG; do
  for action in $ACTION; do

# Directory creation fails when using a path
PREFIX="$PWD/ckpt_${sig}_prefix_absolute"
# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 0) Get pass criterion
PSTR="Simulation Checkpoint"

# 1) Launch the program in the background, running long enough to send signal
#if [[ -f test.$sig.$action.out ]]; then
#  rm test.$sig.$action.out
#fi
echo "SST_COMPONENT_BASE=${SST_COMPONENT_BASE}"
LAUNCH="sst --$sig=$action --checkpoint-prefix=${PREFIX} --add-lib-path=$SST_COMPONENT_BASE/tests/core-debug-components $CONFIG -- $OPTS"
echo $LAUNCH

$LAUNCH > test.$sig.$action.out 2>&1 &

# 2) Get the PID
JOBS=($(jobs -l))
PID=${JOBS[1]}
#echo $PID

# 4) wait for completion 
wait $PID
retVal=$?
echo $sig=$action Complete

# 5) Check result - should fail with invalid checkpoint-prefix
if [ $retVal -eq 0 ]; then
  cat test.$sig.$action.out
  echo "ERROR $sig=$action return code [$retVal]"
  exit $retVal
fi

# Cleanup output directories
if [ $CLEANUP == 1 ]; then
  rm test.$sig.$action.out
fi

done  # for $action
done  # for $sig

echo "PASS"
exit $retVal

