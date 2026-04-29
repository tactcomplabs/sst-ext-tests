#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests restart for a checkpoint that had interactive console to see if the interactive console is carried over."
#EXT_TEST TIMEOUT 120
#
# After v15.0, Interactive console should carry over on checkpoint and should be overridable

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint.py"
PREFIX="ckpt_${TNAME}"
CKPT_DIR="$PREFIX/${PREFIX}_1_100000000000/${PREFIX}_1_100000000000.sstcpt"
CLEANUP=1

#0 Get pass criterion, remove stale ckpt dir, and setup pipe for interactive 
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 1) Launch the program to generate the checkpoint
OUTFILE="$TNAME.ckpt.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

VERBOSE="--verbose=0"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=100ms --interactive-start=1s $VERBOSE $CONFIG"

echo $LAUNCH
$LAUNCH 2>&1 << EOF | tee $OUTFILE | grep -v talking
run
EOF
retVal=$?

echo ckpt Complete [retVal $retVal]

# 2) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR ckpt return code"
  exit $retVal
fi

PSTR="Interactive"
grep -q "$PSTR" ./$OUTFILE
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

# 3) Launch the checkpoint restart
OUTFILE="$TNAME.restart.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --load-checkpoint $VERBOSE $CKPT_DIR"
echo $LAUNCH
#$LAUNCH  > $OUTFILE 2>&1
$LAUNCH 2>&1 | tee $OUTFILE | grep -v talking
retVal=$?

echo restart Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart return code"
  exit $retVal
fi

# Interactive console should NOT carry over to restart for 15.1 and after
grep "$PSTR" $OUTFILE
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR found fail string in $OUTFILE: $PSTR"
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -rf $PREFIX
fi

echo "PASS"
exit $retVal
