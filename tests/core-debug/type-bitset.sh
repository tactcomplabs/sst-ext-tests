#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Exercise std::bitset and std::vector<bool>"
#EXT_TEST TIMEOUT 30

# Settings
CLEANUP=1
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}"
echo "TESTNAME=$TNAME"
CONFIG="dbgsst15.py"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

cat << EOF > $CMDFILE
cd cp0
ls
cd v_bitset42/
ls
p 0
p 3
p 38
p 39
set 39 0
run 1ns
p 39
cd ..
# std::vector<bool> v_vecbool = { true, true, true, true, true, true, true, true};
p v_vecbool
cd v_vecbool
ls
# set bit 7 to 0
set 7 0
run 1ns
ls
# set bit 5 to 1
set 5 1
run 1ns
ls
# change bit 5 back to 0
set 5 0
run 1ns
ls
# invalid value - segfault #TODO test passes if interactive debugger segfaults!!!!
set 2 7
EOF

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s $CONFIG -- --verbose=0"
echo $LAUNCH
# TODO are we checking the tee return code instead of sst?
$LAUNCH << EOF | tee $LOGFILE || exit 1
replay $CMDFILE
confirm false
exit
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

# spot check
# egrep -Pzq "> p 39\s*39 = 1 \(bool\)\N*> set 39 0\N*> p 39\N*39 = 0 \(bool\)" $LOGFILE
grep -q '39 = 1' $LOGFILE
rc0=$?
grep -q '39 = 0' $LOGFILE
rc1=$?

if [ $rc0 -ne 0 ]; then
  echo "Could not find pass string: 39 = 1"
  exit 1
fi

if [ $rc1 -ne 0 ]; then
  echo "Could not find pass string: 39 = 0"
  exit 1
fi


# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit $retVal
