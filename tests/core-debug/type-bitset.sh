#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "Exercise std::bitset and std::vector<bool>"
#EXT_TEST TIMEOUT 30

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

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
confirm false
cd cp0
ls
cd v_bitset42/
ls
# CHECK 0 p 0\n0 = false \(bool\)
p 0
# CHECK 1 p 3\n3 = true \(bool\)
p 3
# CHECK 2 p 38\n38 = false \(bool\)
p 38
# CHECK 3 p 39\n39 = true \(bool\)
p 39
# Flip bits 38 and 39
set 38 1
set 39 0
run 1ns
# CHECK 4 p 38\n38 = true \(bool\)
p 38
# CHECK 5 p 39\n39 = false \(bool\)
p 39
cd ..
# std::vector<bool> v_vecbool  =  { true, false, true, true, false, false, true, true};
p v_vecbool
cd v_vecbool
ls
# CHECK 6 p 5\n5 = false \(bool\)
p 5
# CHECK 7 p 6\n6 = true \(bool\)
p 6
# flip 5 and 6
set 5 1
set 6 0
run 1ns
ls
# CHECK 8 p 5\n5 = true \(bool\)
p 5
# CHECK 9 p 6\n6 = false \(bool\)
p 6

# Invalid setting
set 5 0x10
# CHECK 10 p 5\n5 = true \(bool\)
p 5

# Watch a vector bool bit
watch 7 changed
# CHECK 11 run\nEntering interactive mode
run
ls

# clear all watches
unwatch

# back up to bitset and do the same
cd ..
cd v_bitset42/
watch 41 changed
# CHECK 12 run\nEntering interactive mode
run
ls

EOF

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
# initialize rc to the number of expected checks
awk '
  BEGIN {idx=0; rc=13; lines=""; check=-1 }
  /# CHECK/ { idx=0; lines=""; check=$4; re=substr($0,index($0,$5))}
  { if (check==-1) {next}; 
    lines = sprintf("%s\n%s",lines,$0);
    if (++idx==3) {
      print check; 
      printf("TEST[%d] %s\n",check,lines);
      # printf("RE[%d] %s\n", check, re);
      if (!match(lines,re)) {
        printf("ERROR: Failed TEST[%d]\n",check);
        exit 1;
      }
      rc--; check=-1; idx=0;
    }
  }
  END { exit rc; }
' $LOGFILE

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
