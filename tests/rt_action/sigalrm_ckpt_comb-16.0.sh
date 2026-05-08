#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Tests sigalrm for checkpoint combined with other real time actions"
# 
# 0) set pass string 
# 1) launch the program
# 2) wait for completion
# 3) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

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
SIG="sigalrm"
ACTION="sst.rt.checkpoint"
ACTION2="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat"
CONFIG="rt_action.py"
CLEANUP=1


for sig in $SIG; do
  for action in $ACTION; do
    for action2 in $ACTION2; do

OUTFILE=$TNAME.$action.$action2.out
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

PREFIX="ckpt_$action2"
echo $PREFIX
# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

#0 Get pass criterion
PSTR="Simulation Checkpoint"

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
PSTR2="Components:"
elif [[ $action2 == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR2="Heartbeat"
elif [[ $action2 == "sst.rt.checkpoint" ]]; then
#echo checkpoint
PSTR2="Simulation Checkpoint"
fi

# 1) Launch the program

LAUNCH="sst --$sig=$action(interval=1s);$action2(interval=2s) --checkpoint-prefix=$PREFIX --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- $OPTS"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 

# 2) wait for completion
retVal=$?
echo $sig=$action $action2 Complete retVal $retVal

# 3) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $sig=$action $action2 return code"
  exit $retVal
fi

grep "$PSTR" $OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR"
  exit $retVal
fi

grep "$PSTR2" $OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR2"
  exit $retVal
fi

# Check that checkpoint files exist
if [[ ! -d "$PREFIX" ]]; then
  cat $OUTFILE
  echo "ERROR checkpoint directory '$PREFIX' not found"
  exit 255
fi

echo

# Cleanup output files and directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -r $PREFIX
fi

done  # for $action2
done  # for $action
done  # for $sig

echo "PASS"
exit $retVal

