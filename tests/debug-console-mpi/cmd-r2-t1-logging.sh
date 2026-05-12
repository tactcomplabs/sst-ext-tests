#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Log debug commands to an external file: 2 ranks, 1 thread/rank"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Settings
CLEANUP=1
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="../rt_action/test_Checkpoint.py"
RANKS=2
THREADS=1

OS_TYPE=$(uname -s)
MPIOPTS=""
if [ ${OS_TYPE} = "Linux" ]; then
  MPIOPTS="--bind-to socket"
fi

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

SPOTCHECKS=$(realpath "${SCRIPT_PATH}/../../scripts/spotchecks.awk")
if [ ! -e "${SPOTCHECKS}" ]; then
  echo "Checker script not found. [${SPOTCHECKS}]"
  exit 1
fi

cat << EOF > $CMDFILE
logging $OUTFILE
ls
cd c7
ls
set test_string HelloMyNameIsC7AndICannotQuoteAString
print test_string
continue 1us
rank 0
ls
cd c0
ls
print test_string
shutdown
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=7

# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np $RANKS sst -n $THREADS --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH << EOF | tee $LOGFILE
confirm false
rank 1
replay $CMDFILE
EOF


retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# Should match except for the first 'logging' line
grep -v logging $CMDFILE > $CHKFILE
diff -q $CHKFILE $OUTFILE
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR console output does not match expected result"
  exit $retVal
fi

PSTR="c7 finished. teststring=HelloMyNameIsC7AndICannotQuoteAString"
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
fi

wait
echo "PASS"
exit $retVal
