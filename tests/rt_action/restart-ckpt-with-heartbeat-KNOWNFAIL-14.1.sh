#!/bin/bash
#EXT_TEST TEST_FILE_PARAM 14.1
#EXT_TEST TEST_FILE_DESC "Tests restart for a checkpoint that had heartbeat to see if the heartbeat is carried over. Currently fails with error in restart"
# 
# 0) set pass string and checkpoint directory
# 1) launch the program to generate the checkpoint
# 2) Check the result
# 3) Launch the checkpoint restart
# 4) check result


# Settings
CONFIG="test_Checkpoint.py"
PREFIX="ckpt_restart_heartbeat"
CKPT_DIR="ckpt_restart_heartbeat/ckpt_restart_heartbeat_0_1000000000000/ckpt_restart_heartbeat_0_1000000000000.sstcpt"
CLEANUP=1


#0 Get pass criterion 
PSTR2="Heartbeat"

# 1) Launch the program to generate the checkpoint
OUTFILE="test.ckpt.heartbeat.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --heartbeat-period=2s  $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?

echo ckpt.heartbeat Complete

# 2) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.heartbeat return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.heartbeat grep"
  exit $retVal
fi

# Cleanup output file
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi



# 3) Launch the checkpoint restart
OUTFILE="test.restart.ckpt.heartbeat.out"
LAUNCH="sst --load-checkpoint $CKPT_DIR"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo restart.ckpt.heartbeat Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.heartbeat return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.heartbeat grep"
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

echo "PASS"
exit $retVal






