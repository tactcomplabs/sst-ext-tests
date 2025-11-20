#!/bin/bash
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Check that trace checkpoint action triggers checkpoints"
#EXT_TEST TIMEOUT 30
#
# SST DEV: 

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="test_Checkpoint_4ms.py"
PSTR="Simulation Checkpoint"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
CKPTPREFIX=ckpt_$TNAME

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s --checkpoint-sim-period=5ms --checkpoint-prefix=$CKPTPREFIX $CONFIG"
echo $LAUNCH
$LAUNCH << EOF | tee $LOGFILE || exit 1
cd c0
cd xorshift
trace w changed : 32 4 : w x y z : checkpoint
setHandler 0 ae ac
printWatchpoint 0
run 100us
shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Simulation Complete
PSTR="Simulation is complete"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Check that checkpoint files exist
if [ ! -d "$CKPTPREFIX" ]; then
	echo "ERROR checkpoint directory '$CKPTPREFIX' does not exits"
	exit $retVal
else 
	CKPTFILE="ckpt_cmd-ckptaction-DEV/ckpt_cmd-ckptaction-DEV_1_30000000/ckpt_cmd-ckptaction-DEV_1_30000000.sstcpt"
	if [ ! "$CKPTFILE" ]; then
		echo "ERROR missing $CKPTFILE"
		exit $retVal
	fi
	CKPTFILE="ckpt_cmd-ckptaction-DEV/ckpt_cmd-ckptaction-DEV_1_30000000/ckpt_cmd-ckptaction-DEV_1_30000000_0_0.bin"
	if [ ! "$CKPTFILE" ]; then
		echo "ERROR missing $CKPTFILE"
		exit $retVal
	fi
	CKPTFILE="ckpt_cmd-ckptaction-DEV/ckpt_cmd-ckptaction-DEV_1_30000000/ckpt_cmd-ckptaction-DEV_1_30000000_globals.bin"
	if [ ! "$CKPTFILE" ]; then
		echo "ERROR missing $CKPTFILE"
		exit $retVal
	fi
fi

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
  rm -rf $CKPTPREFIX
fi

wait
echo "PASS"
exit $retVal
