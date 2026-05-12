#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Verify rankserial user-defined commands"
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
CONFIG=$(realpath dbgsst15_4.py)
RANKS=2
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
p -v 1 0
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
p -v 1 first
cd ..
cd ..
end

doc pair_0
First line of pair_0 doc string
Second line of pair_0 doc string
end

# Show help ( not checked )
help

# CHECK 9 tuple_0\n0 = 7 \(
tuple_0

# CHECK 10 pair_0\nfirst = 5 \(
pair_0

# combine into another macro
define duo
tuple_0
pair_0
end

# CHECK 11 duo\n0 = 7 \(.+\nfirst = 5 \(
duo

# multiple levels of nesting
define trio
duo
pair_0
tuple_0
end

# CHECK 12 trio\n0 = 7 \(.+\nfirst = 5 \(.+\nfirst = 5 \(.+\n0 = 7 \(
trio

# define a more useful command using built-in commands only
define tuple_1
cd cp1
cd v_tuple_u32_dbl_str/
p -v 1 1
cd ..
cd ..
end

# Command defined on r0t0, used on r0t1
# CHECK 13 thread 1\n---- Rank0:Thread1: Entering interactive mode at time 1000000
thread 1
# CHECK 14 tuple_1\n1 = 0.142857142857 \(
tuple_1

# Command defined on r0t1, used on r1t1
define tuple_2
cd cp3
cd v_tuple_u32_dbl_str/
p -v 1 2
cd ..
cd ..
end

# CHECK 15 rank 1\n---- Rank1:Thread1: Entering interactive mode at time 1000000
rank 1
# CHECK 16 tuple_2\n2 = "S7" \(
tuple_2

EOF

# Update this whenever adding checks in the command comments above
NUMCHECKS=17

# Launch the program to start interactive mode at time 0
LAUNCH="mpirun ${MPIOPTS} -np $RANKS sst -n $THREADS --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
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
