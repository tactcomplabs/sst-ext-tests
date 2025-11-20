#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.0
#EXT_TEST TEST_FILE_DESC "Tests using interactive console with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check results
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and interactive console
# 4) check result


# Settings
CONFIG=" test_Checkpoint.py"
PREFIX="ckpt4restart_interactive"
CKPTDIR="ckpt4restart_interactive/ckpt4restart_interactive_1_1000000000000/ckpt4restart_interactive_1_1000000000000.sstcpt"
CLEANUP=1

# remove stale checkpoint directory
rm -rf $PREFIX

# 0) Launch the program to generate the checkpoints
OUTFILE="test.ckpt4restart.interactive.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
( $LAUNCH || exit 11 ) | grep -v talking | tee $OUTFILE
echo $PREFIX Done

# 1) Check result
PSTR="Checkpoint"
grep -q "$PSTR" ./$OUTFILE
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $PREFIX grep missing string: $PSTR"
  exit $retVal
fi

# Cleanup output file
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

# 1) Get pass criterion and outputfile
OUTFILE="test.restart.interactive.out"

# 2) Then restart sst with the checkpoint and heartbeat
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=1us --load-checkpoint $CKPTDIR"
echo $LAUNCH
( $LAUNCH << EOF || exit 12 ) | grep -v talking | tee $OUTFILE
run
EOF

wait
echo restart.interactive Complete

# 4) Check result
PSTR="Interactive"
grep -q "$PSTR" ./$OUTFILE
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.interactive grep missing string: $PSTR"
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm -f $OUTFILE
  rm -rf $PREFIX
fi

echo "PASS"
exit 0
