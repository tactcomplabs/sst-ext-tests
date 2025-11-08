#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Tests restart for a checkpoint that had interactive console to see if the interactive console is carried over."
#EXT_TEST TIMEOUT 120
#
# SST DEV: Interactive console should carry over on checkpoint and should be overridable

# 0) set pass string 
# 1) launch the program to generate the checkpoint
# 2) Check the result
# 3) Launch the checkpoint restart with interactive consolse
# 4) check result


# Settings
CONFIG="test_Checkpoint.py"
PREFIX="ckpt_restart_interactive"
CKPT_DIR="ckpt_restart_interactive/ckpt_restart_interactive_1_1000000000000/ckpt_restart_interactive_1_1000000000000.sstcpt"
CLEANUP=1

#0 Get pass criterion and setup pipe for interactive 
PSTR="Interactive"
pipe="/tmp/test_restart_ckpt_pipe"
if [[ ! -p $pipe ]]; then
  echo "Creating pipe: $pipe"
  mkfifo $pipe
fi

# 1) Launch the program to generate the checkpoint
OUTFILE="test.ckpt.interactive.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s --interactive-console=sst.interactive.simpledebug --interactive-start=2s  $CONFIG"

echo $LAUNCH
$LAUNCH <$pipe > $OUTFILE 2>&1 &
exec 3>$pipe

sleep 2
echo run > $pipe

wait
retVal=$?

echo ckpt.interactive Complete

# 2) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.interactive return code"
  rm $pipe
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR ckpt.interactive grep"
  rm $pipe
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
$LAUNCH  > $OUTFILE 2>&1

#$LAUNCH <$pipe  > $OUTFILE 2>&1 &
#exec 3>$pipe
#sleep 2
#echo run > $pipe

wait
retVal=$?

echo restart.ckpt.interactive Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.ckpt.interactive return code"
  rm $pipe
  exit $retVal
fi

# In this example, interactive will not be triggered on restart
# because it is set for 2s AFTER start and it only runs from 1-2s
grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  echo "ERROR restart.ckpt.interactive grep"
  rm $pipe
  exit $retVal
fi

echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -rf $PREFIX*
  rm $pipe
fi

echo "PASS"
exit $retVal






