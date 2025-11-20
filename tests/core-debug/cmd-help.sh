#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Walk through help commands"
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

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
( $LAUNCH << EOF || exit 11 ) | tee $LOGFILE
help
?
help fubar
help addtracevar
help editing
help history
help print
help printtrace
help printwatchpoint
help resettrace 
help run
help set
help sethandler
help trace
help unwatch
help verbose
help watch
help watchlist
help watchpoints
shutdown
EOF

retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $NAME returned $retVal"
  exit $retVal
fi

# Spot check
PSTR='history \[N\]: list previous N instructions'
grep -q "$PSTR" $LOGFILE
if [ $? -ne 0 ]; then
    echo "Error: String not found: $PSTR"
    exit 1
fi

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE $CHKFILE
fi

wait
echo "PASS"
exit 0
