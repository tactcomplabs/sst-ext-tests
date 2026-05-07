#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Tests using sigalrm with restart (i.e. load checkpoint)"
#EXT_TEST TIMEOUT 240

# 
# 0) launch sst to generate the checkpoint
# 1) check result
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and signalrm
# 4) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
SIG="sigalrm"
ACTION="sst.rt.exit.clean sst.rt.exit.emergency sst.rt.status.core sst.rt.status.all sst.rt.heartbeat sst.rt.checkpoint"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt_$TNAME"
CKPTDIR="$PREFIX/${PREFIX}_1_100000000000/${PREFIX}_1_100000000000.sstcpt"
CLEANUP=1

# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 0) Launch the program to generate the checkpoints
OUTFILE="$TNAME.ckpt.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=100ms $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result
PSTR="Checkpoint"
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $PREFIX return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR"
  exit $retVal
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
      PSTR="Components:"
    elif [[ $action == "sst.rt.heartbeat" ]]; then
      #echo heartbeat
      PSTR="Heartbeat"
    elif [[ $action == "sst.rt.checkpoint" ]]; then
      #echo checkpoint
      PSTR="Simulation Checkpoint"
    fi

    OUTFILE="$TNAME.restart.$action.out"
    RS_CKPT_PREFIX="restart_${action}_$TNAME"

    if [[ -f $OUTFILE ]]; then
      rm $OUTFILE
    fi
    if [[ -d $RS_CKPT_PREFIX ]]; then
            rm -rf $RS_CKPT_PREFIX
    fi

# 3) Then restart sst with the checkpoint and sigalrm
if [[ $action == "sst.rt.checkpoint" ]]; then
	LAUNCH="sst --$sig=$action(interval=1s) --load-checkpoint $CKPTDIR --checkpoint-prefix=$RS_CKPT_PREFIX"
else
  LAUNCH="sst --$sig=$action(interval=1s) --load-checkpoint $CKPTDIR"
fi
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 
retVal=$?
echo restart.$sig.$action Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR restart.$sig.$action return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR"
  exit $retVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  if [[ $action == "sst.rt.checkpoint" ]]; then
        rm -r $RS_CKPT_PREFIX
  fi

fi

done  # for $action
done  # for $sig

if [ $CLEANUP -eq 1 ]; then
  rm -r $PREFIX
fi

echo "PASS"
exit $retVal
