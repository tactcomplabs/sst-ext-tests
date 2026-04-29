#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise aggregate types"
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
CONFIG="dbgsst15.py"

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
confirm false

# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

cd cp0
ls

#-- Print intial values

# CHECK 0 p v_ag_class\nv_ag_class \(SSTDEBUG::DbgSST15::ag_class_t\)\n 0 = 42 \(.+\n 1 = ag_class_t \(
p v_ag_class

# CHECK 1 p v_ag_struct\nv_ag_struct \(SSTDEBUG::DbgSST15::ag_struct_t\)\n 0 = 42 \(.+\n 1 = ag_struct_t \(
p v_ag_struct

# Trivially serializable types do not automatically map
# CHECK 2 p v_ag_union\nUnknown object in print command: v_ag_union
p v_ag_union

# CHECK 3 p v_ag_union_struct\nUnknown object in print command: v_ag_union_struct
p v_ag_union_struct

#-- Navigate into objects, print, set and check values

cd v_ag_class
# CHECK 4 ls\n0 = 42 \(.+\n1 = ag_class_t \(
ls
set 0 100
set 1 howdy_class
# CHECK 5 ls\n0 = 100 \(.+\n1 = howdy_class \(
ls

cd ..
cd v_ag_struct
# CHECK 6 ls\n0 = 42 \(.+\n1 = ag_struct_t \(
ls
set 0 200
set 1 howdy_struct
# CHECK 7 ls\n0 = 200 \(.+\n1 = howdy_struct \(
ls

cd ..

### Set watchpoints and run

cd v_ag_class
watch 0 changed
# CHECK 8 setHandler 0 ac\nWP 0 - cp0/v_ag_class/0
setHandler 0 ac
run
# CHECK 9 ls\n0 = 101 \(.+\n1 = 19 \(
ls
run
# CHECK 10 ls\n0 = 102 \(.+\n1 = 38 \(
ls
run
# CHECK 11 ls\n0 = 103 \(.+\n1 = 57 \(
ls
unwatch

cd ..
cd v_ag_struct
watch 0 changed
# CHECK 12 setHandler 0 ac\nWP 0 - cp0/v_ag_struct/0
setHandler 0 ac
run
# CHECK 13 ls\n0 = 203 \(.+\n1 = 69 \(
ls
run
# CHECK 14 ls\n0 = 204 \(.+\n1 = 92 \(
ls
run
# CHECK 15 ls\n0 = 205 \(.+\n1 = 115 \(
ls
unwatch

cd ..

#TODO Traces

shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=16

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug --verbose=$VERBOSE $CONFIG"
echo $LAUNCH
revVal=0
$LAUNCH << EOF  | tee $LOGFILE
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

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
