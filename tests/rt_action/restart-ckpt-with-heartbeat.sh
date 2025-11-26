#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests restart for a checkpoint that had heartbeat to see if the heartbeat is carried over."
#EXT_TEST TIMEOUT 120
#
# After v15.0, Heartbeat SHOULD carry over and SHOULD be overridable

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


#0 Get pass criterion and remove stale checkpoint directory if needed
PSTR2="Heartbeat"
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 1) Launch the program to generate the checkpoint
OUTFILE="$TNAME.ckpt.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=100ms --heartbeat-period=1s  $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1
retVal=$?

echo ckpt Complete

# 2) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR ckpt return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR did not find pass string in $OUTFILE: $PSTR2"
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

LAUNCH="sst --load-checkpoint $CKPT_DIR"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 
retVal=$?

echo restart Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR restart return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  cat $OUTFILE  
  echo "ERROR did not find pass string in $OUTFILE: $PSTR2"
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -rf $PREFIX
fi

echo "PASS"
exit 0
