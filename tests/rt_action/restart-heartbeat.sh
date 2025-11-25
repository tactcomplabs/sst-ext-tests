#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.0
#EXT_TEST TEST_FILE_DESC "Tests using sigalrm with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check resulti
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and sigalrm
# 4) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
ACTION="heartbeat"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt_$TNAME"
CKPTDIR="$PREFIX/${PREFIX}_1_1000000000000/${PREFIX}_1_1000000000000.sstcpt"
CLEANUP=1

# Remove stale checkpoint directory if needed
if [[ -d $PREFIX ]]; then
  echo "Removing stale checkpoint directory: $PREFIX"
  rm -r $PREFIX
fi

# 0) Launch the program to generate the checkpoints
OUTFILE="$TNAME.ckpt.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
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

# 2) Get pass criterion and outputfile
#echo heartbeat
PSTR="Heartbeat"
OUTFILE="$TNAME.restart.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi


# 3) Then restart sst with the checkpoint and heartbeat
LAUNCH="sst --heartbeat-period=2s --load-checkpoint $CKPTDIR"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1 
retVal=$?
echo restart Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.heartbeat return code"
  cat $OUTPUT
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR did not find pass string in $OUTFILE: $PSTR"
  cat $OUTPUT
  exit $retVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -r $PREFIX
fi

echo "PASS"
exit $retVal






