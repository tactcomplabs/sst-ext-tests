#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Test comparisons for different types: all true"
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
PSTR="^Entering interactive mode at time 140000000"

LOGFILE=$TNAME.log
OUTFILE=$TNAME.console.out
CMDFILE=$TNAME.cmd
CHKFILE=$TNAME.chk

# Launch the program to start interactive mode at time 0
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0s --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG"
echo $LAUNCH
$LAUNCH << EOF  | tee $LOGFILE
cd cp0
# bool
watch v_bool == 1
run 1us 
unwatch 0
#watch v_bool != -1
#watch v_bool == 1.0
#watch v_bool == -3.34
watch v_bool == v_bool
run 1us 
unwatch 1
watch v_bool == v_char
run 1us 
unwatch 2
watch v_bool != v_schar
run 1us 
unwatch 3
watch v_bool != v_short
run 1us 
unwatch 4
watch v_bool != v_ushort
run 1us 
unwatch 5
watch v_bool != v_int
run 1us 
unwatch 6
watch v_bool != v_uint
run 1us 
unwatch 7
watch v_bool != v_long
run 1us 
unwatch 8
watch v_bool != v_ulong
run 1us 
unwatch 9
watch v_bool != v_ll
run 1us 
unwatch 10
watch v_bool != v_ull
run 1us 
unwatch 11
watch v_bool == v_float
run 1us 
unwatch 12
watch v_bool != v_double
run 1us 
unwatch 13
watch v_bool != v_ldouble
run 1us 
unwatch 14
# int
watch v_int == -3
run 1us 
unwatch 15
watch v_int != 3
run 1us 
unwatch 16
watch v_int == -3.0
run 1us 
unwatch 17
watch v_int != 3.0
run 1us 
unwatch 18
watch v_int != v_bool
run 1us 
unwatch 19
watch v_int != v_char
run 1us 
unwatch 20
watch v_int != v_schar
run 1us 
unwatch 21
watch v_int != v_short
run 1us 
unwatch 22
watch v_int != v_ushort
run 1us 
unwatch 23
watch v_int == v_int
run 1us 
unwatch 24
watch v_int != v_uint
run 1us 
unwatch 25
watch v_int != v_long
run 1us 
unwatch 26
watch v_int != v_ulong
run 1us 
unwatch 27
watch v_int != v_ll
run 1us 
unwatch 28
watch v_int != v_ull
run 1us 
unwatch 29
watch v_int != v_float
run 1us 
unwatch 30
watch v_int != v_double
run 1us 
unwatch 31
watch v_int != v_ldouble
run 1us 
unwatch 32
# ulong
watch v_ulong == 4
run 1us 
unwatch 33
watch v_ulong != -4
run 1us 
unwatch 34
watch v_ulong == 4.0
run 1us 
unwatch 35
watch v_ulong != -4.0
run 1us 
unwatch 36
watch v_ulong != v_bool
run 1us 
unwatch 37
watch v_ulong != v_char
run 1us 
unwatch 38
watch v_ulong != v_schar
run 1us 
unwatch 39
watch v_ulong != v_short
run 1us 
unwatch 40
watch v_ulong != v_ushort
run 1us 
unwatch 41
watch v_ulong != v_int
run 1us 
unwatch 42
watch v_ulong != v_uint
run 1us 
unwatch 43
watch v_ulong != v_long
run 1us 
unwatch 44
watch v_ulong == v_ulong
run 1us 
unwatch 45
watch v_ulong != v_ll
run 1us 
unwatch 46
watch v_ulong != v_ull
run 1us 
unwatch 47
watch v_ulong != v_float
run 1us 
unwatch 48
watch v_ulong != v_double
run 1us 
unwatch 49
watch v_ulong != v_ldouble
run 1us 
unwatch 50
# float
watch v_float == 1
run 1us 
unwatch 51
watch v_int != -1
run 1us 
unwatch 52
watch v_float == 1.0
run 1us 
unwatch 53
watch v_float != -1.0
run 1us 
unwatch 54
watch v_float == v_bool
run 1us 
unwatch 55
watch v_float == v_char
run 1us 
unwatch 56
watch v_float != v_schar
run 1us 
unwatch 57
watch v_float != v_short
run 1us 
unwatch 58
watch v_float != v_ushort
run 1us 
unwatch 59
watch v_float != v_int
run 1us 
unwatch 60
watch v_float != v_uint
run 1us 
unwatch 61
watch v_float != v_long
run 1us 
unwatch 62
watch v_float != v_ulong
run 1us 
unwatch 63
watch v_float != v_ll
run 1us 
unwatch 64
watch v_float != v_ull
run 1us 
unwatch 65
watch v_float == v_float
run 1us 
unwatch 66
watch v_float != v_double
run 1us 
unwatch 67
watch v_float != v_ldouble
run 1us 
unwatch 68
shutdown
EOF
retVal=$?

echo $TNAME Complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

# v_bool
for (( i=0; i<69; i++ )); do
	PSTR="WP$i:"
	grep "$PSTR" $LOGFILE > /dev/null
	retVal=$?
	if [ $retVal -ne 0 ]; then
	  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
	  exit $retVal
	else 
		echo "Found pass string \"$PSTR\""
	fi
done

PSTR="Simulation is complete, simulated time: 0 s"
grep -q "$PSTR" $LOGFILE
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""


# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE $OUTFILE $CMDFILE
fi

wait
echo "PASS"
exit $retVal
