#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Tests checkpoint with sigalrm to see if the sigalrm is carried over to restart (i.e. load-checkpoint)"
#EXT_TEST TIMEOUT 240

# After v15.0, sigalrm should be carried over on restart and overridable

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
SIG="sigalrm"
ACTION2="sst.rt.status.core sst.rt.status.all sst.rt.heartbeat"
CONFIG="test_Checkpoint.py"
CLEANUP=1

for sig in $SIG; do
  for action2 in $ACTION2; do

#0 Get pass criterion
if [[ $action2 == "sst.rt.status.core" ]]; then
  #echo status.core
  PSTR2="CurrentSimCycle"
elif [[ $action2 == "sst.rt.status.all" ]]; then
  #echo status.all
  PSTR2="Components:"
elif [[ $action2 == "sst.rt.heartbeat" ]]; then
  #echo heartbeat
  PSTR2="Heartbeat"
fi

# Set up for checkpoint
PREFIX="ckpt_${TNAME}_$action2"
CKPTDIR="${PREFIX}/${PREFIX}_1_100000000000/${PREFIX}_1_100000000000.sstcpt"
# Remove stale checkpoint directory if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 1) Launch sst with sigalrm actions to generate the checkpoint file
OUTFILE="$TNAME.ckpt.$action2.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=100ms --sigalrm=$action2(interval=1s) $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1
retVal=$?

echo ckpt.$sig.$action2 Complete

# 2) Check result
if [ $retVal -ne 0 ]; then
  #cat $OUTFILE
  echo "ERROR ckpt.$sig.$action2 return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  #cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR2"
  exit $retVal
fi

if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

# 3) Launch sst with ckpt file (restart)
OUTFILE="$TNAME.restart.$action2.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --load-checkpoint $CKPTDIR"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo restart.$sig.$action2 Complete

# 4) Check result (sigalrm actions should carry over to restart)
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.$sig.$action2 return code"
  #cat $OUTFILE
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR did not find pass string in $OUTFILE: $PSTR2"
  #cat $OUTFILE
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -rf $PREFIX
fi

done  # for $action2
done  # for $sig

echo "PASS"
exit 0






