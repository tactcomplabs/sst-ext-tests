#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests CaptCrunch simple data integrity"

TEST_NAME=CaptCrunch_Simple1

rm -Rf $TEST_NAME.py
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

wait

# -- run the first pass through the sim
echo "SST_COMPONENT_BASE=${SST_COMPONENT_BASE}"
sst --checkpoint-period=10ns --checkpoint-prefix=$TEST_NAME-PRE --add-lib-path=$SST_COMPONENT_BASE/CaptCrunch/ $TEST_NAME.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi

CPTFILE=`find ./$TEST_NAME-PRE -name "$TEST_NAME-PRE_9_*" | grep sstcpt`

# -- restart the sim from a known good checkpoint
sst --load-checkpoint --checkpoint-period=10ns --checkpoint-prefix=$TEST_NAME-POST --add-lib-path=$SST_COMPONENT_BASE/CaptCrunch/ $CPTFILE

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
