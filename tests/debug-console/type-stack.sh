#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise std::stack<unsigned>"
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
# CHECK 0 p v_stack_unsigned\nv_stack_unsigned \[
p v_stack_unsigned

cd v_stack_unsigned
# CHECK 1 ls\ncontainer \[3 elem.+
ls

# CHECK 2 p -v 2 container\ncontainer .+\n0 = 10 .+\n1 = 20 .+\n2 = 30
p -v 2 container

cd container
# CHECK 3 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 30
ls -l

# CHECK 4 p -v 1 0\n0 = 10
p -v 1 0

# CHECK 5 p -v 1 1\n1 = 20
p -v 1 1

# CHECK 6 p -v 1 2\n2 = 30
p -v 1 2

watch 0 changed
watch 1 changed
watch 2 changed
run

# CHECK 7 pwd\n/cp0/v_stack_unsigned/container
pwd

# CHECK 8 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 31 .+
ls -l

run
# CHECK 9 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 32 .+
ls -l

run
# CHECK 10 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 33 .+
ls -l

run
# CHECK 11 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 34 .+
ls -l

set 2 200
# CHECK 12 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 200 .+
ls -l

run
run
# CHECK 13 ls -l\n0 = 10 .+\n1 = 20 .+\n2 = 201 .+
ls -l

# stack does not have an emplace member function but we can still write values in the debugger
set 0 100
set 1 150
# CHECK 14 ls -l\n0 = 100 .+\n1 = 150 .+\n2 = 201 .+
ls -l

run
run
# CHECK 15 ls -l\n0 = 100 .+\n1 = 150 .+\n2 = 202 .+
ls -l

# now do a trace
unwatch

# CHECK 16 trace 2 changed  : 4 2 : 0 1 2 : interactive\nAdded watchpoint #0
trace 2 changed  : 4 2 : 0 1 2 : interactive

sethandler 0 ac
run

# TODO add this check when iconsole is merged. The current checker can't handle optional lines.
# --check-- 17 printTrace 0\nTriggerRecord:@cycle7700000: samples lost = 0:.+\nbuf\[2] AC .+ \(-) cp0.+/2=202[ ]*\nbuf\[3] AC .+ \(\!) cp0.+/2=203[ ]*\nbuf\[0] AC .+ \(\+) cp0.+/2=203[ ]*\nbuf\[1] AC .+ \(\+) cp0.+/2=203
printTrace 0

# Expected when iconsole branch merged
# TriggerCount=1 <-- HERE this is being added
# TriggerRecord:@cycle7700000: samples lost = 0: cp0/v_stack_unsigned/container/0=100 cp0/v_stack_unsigned/container/1=150 cp0/v_stack_unsigned/container/2=203 
# buf[2] AC @7699000 (-) cp0/v_stack_unsigned/container/0=100 cp0/v_stack_unsigned/container/1=150 cp0/v_stack_unsigned/container/2=202 
# buf[3] AC @7700000 (!) cp0/v_stack_unsigned/container/0=100 cp0/v_stack_unsigned/container/1=150 cp0/v_stack_unsigned/container/2=203 
# buf[0] AC @7701000 (+) cp0/v_stack_unsigned/container/0=100 cp0/v_stack_unsigned/container/1=150 cp0/v_stack_unsigned/container/2=203 
# buf[1] AC @7702000 (+) cp0/v_stack_unsigned/container/0=100 cp0/v_stack_unsigned/container/1=150 cp0/v_stack_unsigned/container/2=203 


shutdown

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=17

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
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
