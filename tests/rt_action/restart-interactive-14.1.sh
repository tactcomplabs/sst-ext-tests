#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 14.1
#EXT_TEST TEST_FILE_MAXVER 14.1
#EXT_TEST TEST_FILE_DESC "Tests using interactive console with restart (i.e. load checkpoint)"
# 
# 0) launch sst to generate the checkpoint
# 1) check results
# 2) set pass string and output file
# 3) restart sst with the checkpoint file and interactive console
# 4) check result


# Settings
CONFIG=" test_Checkpoint.py" #test_MessageMesh.py"
PREFIX="ckpt4restart_interactive"
CKPTDIR="ckpt4restart_interactive/ckpt4restart_interactive_0_1000000000000/ckpt4restart_interactive_0_1000000000000.sstcpt"
CLEANUP=1


# 0) Launch the program to generate the checkpoints
OUTFILE="test.ckpt4restart.interactive.out"
LAUNCH="sst --checkpoint-prefix=$PREFIX --checkpoint-sim-period=1s $CONFIG"
echo $LAUNCH
eval $LAUNCH > $OUTFILE 2>&1
retVal=$?
echo $PREFIX Done

# 1) Check result
PSTR="Checkpoint"
if [ $retVal -ne 0 ]; then
  echo "ERROR $PREFIX return code"
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR $PREFIX grep"
  exit $retVal
fi

# Cleanup output file
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
fi

# 1) Get pass criterion and outputfile
#echo heartbeat
PSTR="Interactive"
OUTFILE="test.restart.interactive.out"

# 2) Set up pipe for interactive
pipe="/tmp/test_restart_pipe"
if [[ ! -p $pipe ]]; then
  echo "Creating pipe: $pipe"
  mkfifo $pipe
fi

# 3) Then restart sst with the checkpoint and heartbeat
if [[ -f $OUTFILE ]]; then
  rm $OUTFILE
fi

LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=1us --load-checkpoint $CKPTDIR"
echo $LAUNCH
$LAUNCH < $pipe > $OUTFILE 2>&1 &
exec 3>$pipe

sleep 2
echo run > $pipe

wait
retVal=$?
echo restart.interactive Complete

# 4) Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.interactive return code"
  rm $pipe
  exit $retVal
fi

grep "$PSTR" ./$OUTFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR restart.interactive grep"
  rm $pipe
  exit $retVal
fi
echo

# Cleanup output directories
if [ $CLEANUP -eq 1 ]; then
  rm $OUTFILE
  rm -r $PREFIX
  rm $pipe
fi

echo "PASS"
exit $retVal






