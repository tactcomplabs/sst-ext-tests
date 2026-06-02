#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "4rank/2thread trace action buffer reset examples"
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
CONFIG=$(realpath ../remap/loop101.py)
RANKS=4
THREADS=2

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk
CKPTPREFIX=ckpt_$TNAME
SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

# Console commands part 1: Enter interactive and generate a checkpoint
cat << EOF > $CMDFILE
confirm false
# CHECK 1 pwd
pwd
rank 1
thread 1
cd cp42

# printTrace and checkpoint actions will occur before synchronization point and continue sampling.
# printing their trace buffers will show the values up to the synchronization point.
trace tickle_counter == 100 : 3 1 : curCycle tickle_counter : printTrace
trace tickle_counter == 100 : 3 1 : curCycle tickle_counter : checkpoint

# interactive action will occur at the synchronization and will contain a trigger
trace tickle_counter == 100 : 3 1 : curCycle tickle_counter : interactive

run

# printTrace action: at synchronization point will likely not include a trigger
printTrace 0

# TriggerCount=204
# buf[2] AC @1999680 (-) curCycle = 15 tickle_counter = 104 
# buf[0] BC @1999872 (-) curCycle = 15 tickle_counter = 104 
# buf[1] AC @1999872 (-) curCycle = 16 tickle_counter = 104 

# checkpoint action: at synchronization should match watchpoint 0
printTrace 1

# TriggerCount=204
# buf[2] AC @1999680 (-) curCycle = 15 tickle_counter = 104 
# buf[0] BC @1999872 (-) curCycle = 15 tickle_counter = 104 
# buf[1] AC @1999872 (-) curCycle = 16 tickle_counter = 104 

# interactive action: This will include the trigger
# CHECK 2 printTrace 2\nTriggerCount=204\nLastTriggerRecord:@cycle1920192: SamplesLost=0: curCycle = 0 tickle_counter = 100.*\nbuf\[2] BC @1920000 \(-) curCycle = 99 tickle_counter = 99.+\nbuf\[0] AC @1920000 \(!) curCycle = 0 tickle_counter = 100.+\nbuf\[1] BC @1920192 \(\+) curCycle = 0 tickle_counter = 100
printTrace 2

# TriggerCount=204
# LastTriggerRecord:@cycle1920192: SamplesLost=0: curCycle = 0 tickle_counter = 100 
# buf[2] BC @1920000 (-) curCycle = 99 tickle_counter = 99 
# buf[0] AC @1920000 (!) curCycle = 0 tickle_counter = 100 
# buf[1] BC @1920192 (+) curCycle = 0 tickle_counter = 100 

unwatch
run
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=2

# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np $RANKS sst --checkpoint-enable  --verbose=$VERBOSE -n $THREADS --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
( $LAUNCH 2>&1 << EOF || exit 11 ) | tee  $LOGFILE
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

# Simulation Complete
PSTR="Simulation is complete, simulated time: 1.0017 ms"
grep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
  rm -rf $CKPTPREFIX
fi

wait
echo "PASS"
exit 0
