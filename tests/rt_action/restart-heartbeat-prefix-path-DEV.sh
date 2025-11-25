#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Tests expected fail passing path to checkpoint-prefix"

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
ACTION="heartbeat"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="$PWD/ckpt_$TNAME"
CKPTDIR="$PREFIX/ckpt_${TNAME}_1_1000000000000/ckpt_${TNAME}_1_1000000000000.sstcpt"
CLEANUP=1

# Remove stale checkpoint dir if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 0) Launch the program to generate the checkpoints
OUTFILE="$TNAME.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result - should fail with invalid checkpoint-prefix
if [ $retVal -eq 0 ]; then
  cat $OUTFILE
  echo "ERROR $PREFIX return code"
  exit 255
fi

echo "PASS"
exit 0






