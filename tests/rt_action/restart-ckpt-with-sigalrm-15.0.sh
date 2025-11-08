#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.0
#EXT_TEST TEST_FILE_DESC "Tests checkpoint with sigalrm to see if the sigalrm is carried over to restart (i.e. load-checkpoint)"
# 
# 0) set pass string
# 1) launch sst to generate the checkpoint
# 2) check result
# 3) restart sst with the checkpoint file
# 3) check result


# Settings
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
  PSTR2="TimeVortex state"
elif [[ $action2 == "sst.rt.heartbeat" ]]; then
  #echo heartbeat
  PSTR2="Heartbeat"
fi

PREFIX="ckpt_sigalrm_$action2"
CKPTDIR="ckpt_sigalrm_$action2/ckpt_sigalrm_${action2}_1_1000000000000/ckpt_sigalrm_${action2}_1_1000000000000.sstcpt"


# 1) Launch sst with sigalrm actions to generate the checkpoint file
#if [[ -f $OUTFILE ]]; then
#  rm $OUTFILE
#fi
OUTFILE="test.ckpt.$sig.$action2.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --sigalrm='$action2(interval=1s)' $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?

echo ckpt.$sig.$action2 Complete


# 2) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.$sig.$action2 return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.$sig.$action2 grep"
  exit $retVal
fi

if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

# 3) Launch sst with ckpt file (restart)
OUTFILE="test.restart.ckpt.$sig.$action2.out"
LAUNCH="sst --load-checkpoint $CKPTDIR"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo restart.ckpt.$sig.$action2 Complete

# 4) Check result (sigalrm actions should NOT appear at restart so it checks that PSTR does NOT appear)
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.$sig.$action2 return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR restart.ckpt.$sig.$action grep"
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

if [ $CLEANUP -eq 1 ]; then
  rm -rf $PREFIX*
fi

done  # for $action2
done  # for $sig

echo "PASS"
exit $retVal






