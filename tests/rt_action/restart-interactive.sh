#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.0
#EXT_TEST TEST_FILE_DESC "Tests using interactive console with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check results
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and interactive console
# 4) check result

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# Settings
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt_$TNAME"
CKPTDIR="$PREFIX/${PREFIX}_1_1000000000000/${PREFIX}_1_1000000000000.sstcpt"
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

LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
$LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR $PREFIX return code"
  exit $retVal
fi

PSTR="Checkpoint"
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

# 1) Get outputfile
OUTFILE="$TNAME.restart.out"
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

# 3) Then restart sst with the checkpoint and interactive
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=1s --load-checkpoint $CKPTDIR"
echo $LAUNCH
$LAUNCH << EOF > $OUTFILE 2>&1
run
EOF

retVal=$?
echo restart.interactive Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  cat $OUTFILE
  echo "ERROR restart.interactive return code"
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
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -rf $PREFIX
fi

echo "PASS"
exit 0






