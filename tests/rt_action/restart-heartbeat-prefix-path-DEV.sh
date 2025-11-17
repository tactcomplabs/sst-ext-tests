#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Tests expected fail passing path to checkpoint-prefix"

# Settings
ACTION="heartbeat"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="$PWD/ckpt4restart_heartbeat_abs"
CKPTDIR="ckpt4restart_heartbeat_abs/ckpt4restart_heartbeat_abs_1_1000000000000/ckpt4restart_heartbeat_abs_1_1000000000000.sstcpt"
CLEANUP=1

# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 0) Launch the program to generate the checkpoints
OUTFILE="test.ckpt4restart.heartbeat.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result - should fail with invalid checkpoint-prefix
if [ $retVal -eq 0 ]; then
  echo "ERROR $PREFIX return code"
  exit 255
fi

echo "PASS"
exit 0






