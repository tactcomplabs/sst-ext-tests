#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "short std::pair watch test"
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
cd cp0
p v_pair_u64_str
cd v_pair_u64_str/
watch 0 changed
run
# CHECK 0 p 0\n0 = 5 \(unsigned long( long)?\)
p 0
# CHECK 1 p 1\n1 = S5 \(std::string\)
p 1
confirm false
unwatch
EOF

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
# initialize rc to the number of expected checks
awk '
  BEGIN {idx=0; rc=2; lines=""; check=-1 }
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
