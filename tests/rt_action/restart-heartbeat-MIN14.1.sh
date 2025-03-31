#!/bin/bash
#EXT_TEST TEST_FILE_PARAM MIN14.1
#EXT_TEST TEST_FILE_DESC "Tests using sigalrm with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check resulti
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and sigalrm
# 4) check result


# Settings
ACTION="heartbeat"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt4restart_heartbeat"
CKPTDIR="ckpt4restart_heartbeat/ckpt4restart_heartbeat_0_1000000000000/ckpt4restart_heartbeat_0_1000000000000.sstcpt"
CLEANUP=1


# 0) Launch the program to generate the checkpoints
OUTFILE="test.ckpt4restart.heartbeat.out"
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

# 2) Get pass criterion and outputfile
#echo heartbeat
PSTR="Heartbeat"
OUTFILE="test.restart.heartbeat.out"

# 3) Then restart sst with the checkpoint and heartbeat
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --heartbeat-period=2s --load-checkpoint $CKPTDIR"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1 
retVal=$?
echo restart.heartbeat Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.heartbeat return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.heartbeat grep"
  exit $grepVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -r $PREFIX
fi

echo "PASS"
exit $retVal






