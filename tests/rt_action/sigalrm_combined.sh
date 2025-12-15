#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests sigalrm for combinations of two real time actions (checkpoint not included)"
#EXT_TEST TIMEOUT 90
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
ACTION="sst.rt.status.core sst.rt.status.all sst.rt.heartbeat"
ACTION2="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat"
CONFIG="rt_action.py"
CLEANUP=1

for sig in $SIG; do
  for action in $ACTION; do
    for action2 in $ACTION2; do

if [[ $action != $action2 ]]; then

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
PSTR="Components:"
elif [[ $action == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR="Heartbeat"
fi


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
PSTR2="Components:"
elif [[ $action2 == "sst.rt.heartbeat" ]]; then
#echo heartbeat
PSTR2="Heartbeat"
fi

OUTFILE="$TNAME.$action.$action2.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

# 1) Launch the program
LAUNCH="sst --$sig=$action(interval=1s);$action2(interval=2s) --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- $OPTS"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 

# 2) wait for completion 
retVal=$?
echo $sig=$action $action2 Complete

# 3) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $sig=$action $action2 return code"
  cat $OUTFILE
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $sig=$action did not find passing string in $OUTFILE: $PSTR"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $sig=$action2 did not find passing string in $OUTFILE: $PSTR"
  exit $retVal
fi

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

echo
fi    # if $action != $action2

done  # for $action2
done  # for $action
done  # for $sig

echo "PASS"
exit $retVal
