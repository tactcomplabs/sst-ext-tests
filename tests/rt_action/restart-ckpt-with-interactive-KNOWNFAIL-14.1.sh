#!/bin/bash
#EXT_TEST TEST_FILE_PARAM 14.1
#EXT_TEST TEST_FILE_DESC "Tests restart for a checkpoint that had interactive console to see if the interactive console is carried over. Currently Fails"

# 0) set pass string 
# 1) launch the program to generate the checkpoint
# 2) Check the result
# 3) Launch the checkpoint restart with interactive consolse
# 4) check result


# Settings
CONFIG="test_Checkpoint.py"
PREFIX="ckpt_restart_interactive"
CKPT_DIR="ckpt_restart_interactive/ckpt_restart_interactive_0_1000000000000/ckpt_restart_interactive_0_1000000000000.sstcpt"
CLEANUP=1

#0 Get pass criterion 
PSTR2="Interactive"

# 1) Launch the program to generate the checkpoint
OUTFILE="test.ckpt.interactive.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --interactive-console=sst.interactive.simpledebug --interactive-start=2s  $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?

echo ckpt.interactive Complete

# 2) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.interactive return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.interactive grep"
  exit $retVal
fi

# Cleanup output file
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi


# 3) Launch the checkpoint restart
OUTFILE="test.restart.ckpt.interactive.out"
LAUNCH="sst --load-checkpoint $CKPT_DIR"
echo $LAUNCH
exec $LAUNCH > $OUTFILE 2>&1 
retVal=$?
echo restart.ckpt.interactive Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.interactive return code"
  exit $retVal
fi

grep "$PSTR2" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.interactive grep"
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






