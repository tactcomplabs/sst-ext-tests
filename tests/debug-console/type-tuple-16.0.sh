#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_MAXVER 16.0
#EXT_TEST TEST_FILE_DESC "Exercise std::pair and std::tuple"
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
cd cp0
ls

# The pair
p v_pair_u64_str
cd v_pair_u64_str/
ls
# CHECK 0 p first\nfirst = 42 \(unsigned long( long)?\)
p first
# CHECK 1 p second\nsecond = forty-two \(std::string\)
p second
# Change values
set first 11
set second eleven
run 1ns
# CHECK 2 p first\nfirst = 11 \(unsigned long( long)?\)
p first
# CHECK 3 p second\nsecond = eleven \(std::string\)
p second
# Set watch on numeric type (cannot do string at the moment)
watch first changed
run
ls
# CHECK 4 p first\nfirst = 5 \(unsigned long( long)?\)
p first
# CHECK 5 p second\nsecond = S5 \(std::string\)
p second
unwatch

# The tuple
cd ..
p v_tuple_u32_dbl_str
cd v_tuple_u32_dbl_str/
ls
# CHECK 6 p 0\n0 = 8 \(unsigned int\)
p 0
# CHECK 7 p 1\n1 = 0.1250.+ \(double\)
p 1
# CHECK 8 p 2\n2 = eight \(std::string\)
p 2
# Change values
s 0 1
s 1 1.0
s 2 one
run 1ns
ls
# CHECK 9 p 0\n0 = 1 \(unsigned int\)
p 0
# CHECK 10 p 1\n1 = 1.0.+ \(double\)
p 1
# CHECK 11 p 2\n2 = one \(std::string\)
p 2
# watch it
watch 0 changed
run
ls
# CHECK 12 p 0\n0 = 7 \(unsigned int\)
p 0
# CHECK 13 p 1\n1 = 0.142.+ \(double\)
p 1
# CHECK 14 p 2\n2 = S7 \(std::string\)
p 2
shutdown
EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=15

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
echo $LAUNCH
revVal=0
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

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
