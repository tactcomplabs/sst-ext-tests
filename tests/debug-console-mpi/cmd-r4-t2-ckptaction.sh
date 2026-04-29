#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Check trace checkpoint action for RankParallel: 4 ranks, 2 threads/rank for ranks 1 & 3"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Convenience environment variables
set +u
if [[ -z "${CLEANUP}" ]]; then
CLEANUP=1
fi
if [[ -z "${VERBOSE}" ]]; then
  VERBOSE=0
fi

set -u

# Common settings
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG=$(realpath ../debug-console/test_Checkpoint_4ms.py)
RANKS=4
THREADS=2

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
CKPTPREFIX=ckpt_$TNAME

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

# Console commands
cat << EOF > $CMDFILE
# rank 1 thread 0 c2
# CHECK 0 rank 1\n---- Rank1:Thread0: Entering interactive mode at time 1000000
rank 1
cd c2
cd xorshift
trace w changed : 32 4 : w x y z : checkpoint
setHandler 0 ae ac
# CHECK 1 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : /c2/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : checkpoint
printWatchpoint 0
run 40us
rank 1
wl
unwatch 0
# rank 3 thread 1 c7
rank 3
# CHECK 2 thread 1\n---- Rank3:Thread1: Entering interactive mode at time 41000000
thread 1
cd c7
cd xorshift
trace w changed : 32 4 : w x y z : checkpoint
setHandler 0 ae ac
# CHECK 3 printWatchpoint 0\nWP0: TriggerCount 0 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : checkpoint
printWatchpoint 0
run 40us
rank 3
thread 1
wl
unwatch 0
run
EOF

# for later
# CHECK 1 run100us.+\n# Simulation Checkpoint: Simulated Time 96 us
# CHECK 2 shutdown.+\nSimulation is complete, simulated time: 0 s

# Update this whenever adding checks in the command comments above
NUMCHECKS=4

# Remove stale checkpoint directory if necessary
if [ -d "$CKPTPREFIX" ]; then
        echo "Removing stale checkpoint directory '$CKPTPREFIX'"
        rm -rf $CKPTPREFIX
fi


# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np $RANKS sst --verbose=$VERBOSE -n $THREADS --interactive-start=0s --checkpoint-enable --checkpoint-prefix=$CKPTPREFIX $CONFIG"
echo $LAUNCH
( $LAUNCH << EOF || exit 11 ) | tee $LOGFILE
replay $CMDFILE
confirm false
exit
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# spot checks
# First argument is the number of expected checks
${SPOTCHECKS} $NUMCHECKS $LOGFILE

RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: Test Failed with RC=$RC"
  exit $RC
fi

# ---- rank 1 thread 0 c2
# Checkpoint @ 41us
PSTR="# Simulation Checkpoint: Simulated Time 41 us"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
    fi
    echo "Found pass string \"$PSTR\""

# Checkpoint in WL
PSTR="0: TriggerCount 0 : AC AE : /c2/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : checkpoint"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# ---- rank 3 thread 1 c7
# Checkpoint @ 81us
PSTR="# Simulation Checkpoint: Simulated Time 81 us"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Checkpoint in WL
PSTR="0: TriggerCount 1 : AC AE : /c7/xorshift/w CHANGED  : bufsize = 32 postDelay = 4 : w x y z  : checkpoint"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Simulation Complete
PSTR="Simulation is complete, simulated time: 4.007 ms"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Check that checkpoint files exist
if [ ! -d "$CKPTPREFIX" ]; then
	echo "ERROR checkpoint directory '$CKPTPREFIX' does not exist"
	exit $retVal
else 
	CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000.sstcpt"
	if [ ! "$CKPTFILE" ]; then
		echo "ERROR missing $CKPTFILE"
		exit $retVal
	fi
	CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000_0_0.bin"
	if [ ! "$CKPTFILE" ]; then
		echo "ERROR missing $CKPTFILE"
		exit $retVal
	fi
        # Should be a bin file for each thread
        CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000_0_1.bin"
        if [ ! "$CKPTFILE" ]; then
                echo "ERROR missing $CKPTFILE"
                exit $retVal
        fi
        CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000_0_2.bin"
        if [ ! "$CKPTFILE" ]; then
                echo "ERROR missing $CKPTFILE"
                exit $retVal
        fi
        CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000_0_3.bin"
        if [ ! "$CKPTFILE" ]; then
                echo "ERROR missing $CKPTFILE"
                exit $retVal
        fi
	CKPTFILE="${CKPTPREFIX}/${CKPTPREFIX}_1_30000000/${CKPTPREFIX}_1_30000000_globals.bin"
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
exit 0
