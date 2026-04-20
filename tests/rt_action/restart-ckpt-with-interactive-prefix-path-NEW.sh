#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Tests expected fail for passing path to checkpoint-prefix."
#EXT_TEST TIMEOUT 120
#
# DEV: Passing a path to checkpoint prefix should fail

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint.py"
PREFIX="$PWD/ckpt_$TNAME"
CLEANUP=1

#Remove stale checkpoint directory if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 1) Launch the program to generate the checkpoint
OUTFILE="$TNAME.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --interactive-start=2s  $CONFIG"

echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo ckpt Complete

# 2) Check result - should fail with invalid checkpoint-prefix
if [ $retVal -eq 0 ]; then
  cat $OUTFILE
  echo "ERROR ckpt return code"
  exit $retVal
fi

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

echo
echo "PASS"
exit $retVal






