#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Exercise std::bitset and std::vector<bool>"
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

# CHECK 0 define ls\nCannot overwrite built-in command "ls"
define ls

# CHECK 1 define fubar\nEnter commands for "fubar" terminated by "end"\n.+ fubar\nfubar cannot call itself
define fubar
fubar
end

# CHECK 2 define fubar\nEnter commands for "fubar" terminated by "end"\n.+ def\nIgnoring entry: define/def
define fubar
def
end

# CHECK 3 define fubar\nEnter commands for "fubar" terminated by "end"\n.+ doc\nIgnoring entry: document/doc
define fubar
doc
end

# CHECK 4 define fubar\nEnter commands for "fubar" terminated by "end"\n.+ doc\nIgnoring entry: document/doc
define fubar
doc
end

# CHECK 5 def ls\nCannot overwrite built-in command "ls"
def ls

# CHECK 6 doc ls\nCannot overwrite built-in command "ls"
doc ls

# CHECK 7 doc nothing\n"nothing" must be defined before documenting
doc nothing

# empty commands should do nothing
define empty
end

# CHECK 8 empty\n.+ #nada
empty
#nada

# define a more useful command using built-in commands only
define tuple_0
cd cp0
cd v_tuple_u32_dbl_str/
p 0
cd ..
cd ..
end

doc tuple_0
First line of tuple_0 doc string
Second line of tuple_0 doc string
end

# define a more useful command using built-in commands only
define pair_0
cd cp0
cd v_pair_u64_str/
p 0
cd ..
cd ..
end

doc pair_0
First line of pair_0 doc string
Second line of pair_0 doc string
end

# Show help ( not checked )
help

# CHECK 9 tuple_0\n0 = 8 \(
tuple_0

# CHECK 10 pair_0\n0 = 42 \(
pair_0

# combine into another macro
define duo
tuple_0
pair_0
end

# CHECK 11 duo\n0 = 8 \(.+\n0 = 42 \(
duo

# multiple levels of nesting
define trio
duo
pair_0
tuple_0
end

# CHECK 12 trio\n0 = 8 \(.+\n0 = 42 \(.+\n0 = 42 \(.+\n0 = 8 \(
trio

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=13

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
