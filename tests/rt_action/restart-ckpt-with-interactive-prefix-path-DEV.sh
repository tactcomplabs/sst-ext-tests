#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Tests expected fail for passing path to checkpoint-prefix."
#EXT_TEST TIMEOUT 120
#
# DEV: Passing a path to checkpoint prefix should fail

# Settings
CONFIG="test_Checkpoint.py"
PREFIX="$PWD/ckpt_restart_interactive_path"
CLEANUP=1

# 1) Launch the program to generate the checkpoint
OUTFILE="test.ckpt.interactive.prefix.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --interactive-console=sst.interactive.simpledebug --interactive-start=2s  $CONFIG"

echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo ckpt.interactive.prefix Complete

# 2) Check result - should fail with invalid checkpoint-prefix
if [ $retVal -eq 0 ]; then
  echo "ERROR ckpt.interactive.prefix return code"
  exit $retVal
fi

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

echo
echo "PASS"
exit $retVal






