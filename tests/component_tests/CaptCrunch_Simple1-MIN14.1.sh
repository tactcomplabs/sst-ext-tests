#!/bin/bash
#EXT_TEST TEST_FILE_PARAM MIN14.1
#EXT_TEST TEST_FILE_DESC "Tests CaptCrunch simple data integrity"

TEST_NAME=CaptCrunch_Simple1-MIN14.1

cat > $TEST_NAME.py << EOL
import sst
sst.setStatisticLoadLevel(4)
sst.enableAllStatisticsForAllComponents()
sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "$TEST_NAME.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunch.CaptCrunch")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "10000"
})
EOL

# -- run the first pass through the sim
sst --checkpoint-period=10ns --checkpoint-prefix=$TEST_NAME-PRE --add-lib-path=${CMAKE_BINARY_DIR}/tests/components/CaptCrunch/ CaptCrunch_Simple1-DEV.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

# -- restart the sim from a known good checkpoint
sst --load-checkpoint --checkpoint-period=10ns --checkpoint-prefix=$TEST_NAME-POST --add-lib-path=${CMAKE_BINARY_DIR}/tests/components/CaptCrunch/ ./$TEST_NAME-PRE/$TEST_NAME-PRE_9_100000/$TEST_NAME-PRE_9_100000.sstcpt

retVal=$?

rm -Rf ./$TEST_NAME-PRE
rm -Rf ./$TEST_NAME-POST
rm $TEST_NAME.py
rm $TEST_NAME.csv

if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
else
  echo "PASS"
  exit 0
fi

exit 0
