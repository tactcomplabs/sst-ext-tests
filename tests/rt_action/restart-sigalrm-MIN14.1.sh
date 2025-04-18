#!/bin/bash
#EXT_TEST TEST_FILE_PARAM MIN14.1
#EXT_TEST TEST_FILE_DESC "Tests using sigalrm with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check result
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and signalrm
# 4) check result


# Settings
SIG="sigalrm"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt4restart_sigalrm"
CKPTDIR="ckpt4restart_sigalrm/ckpt4restart_sigalrm_1_1000000000000/ckpt4restart_sigalrm_1_1000000000000.sstcpt"
CLEANUP=1


# 0) Launch the program to generate the checkpoints
OUTFILE="test.ckpt4restart.sigalrm.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result
PSTR="Checkpoint"
if [ $retVal -ne 0 ]; then
  echo "ERROR $PREFIX return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $PREFIX grep"
  exit $grepVal
fi

# Cleanup output file
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi


for sig in $SIG; do
  for action in $ACTION; do

# 2) Get pass criterion and outputfile
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

OUTFILE="test.restart.$sig.$action.out"

# 3) Then restart sst with the checkpoint and sigalrm
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --$sig='$action(interval=1s)' --load-checkpoint $CKPTDIR"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1 
retVal=$?
echo restart.$sig.$action Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.$sig.$action return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.$sig.$action grep"
  exit $grepVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi


done  # for $action
done  # for $sig

if [ $CLEANUP -eq 1 ]; then
  rm -r $PREFIX
  rm -r ${PREFIX}_1
fi

echo "PASS"
exit $retVal






