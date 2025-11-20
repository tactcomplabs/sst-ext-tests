#!/usr/bin/env bash
echo $CWD

TEST_NAME=eCaptCrunchObjMap_$1-DEV
LAUNCH="sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 $TEST_NAME.py"
LOGFILE=eCaptCrunchObjMap_$1-DEV.log
echo $LAUNCH
$LAUNCH << EOF | tee $LOGFILE || exit
examine c0
EOF

TEST_NAME=eCaptCrunchObjMap_$1-DEV
LOGFILE=eCaptCrunchObjMap_$1-DEV.log
rm $TEST_NAME.py
rm $TEST_NAME.csv

diff examine_$1.res $LOGFILE
ret=$?
rm $LOGFILE

VALUE="FAIL"
if [[ $ret -eq 0 ]]; then
   VALUE="PASS"
fi

echo "$VALUE"
