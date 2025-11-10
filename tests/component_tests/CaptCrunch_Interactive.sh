#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "Tests CaptCrunch simple data integrity"

TEST_NAME=CaptCrunch_Interactive

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

# -- for starters just enter 1 component and do not segfault
# -- TODO print and check. Each data member through the heirarchy
# -- run the first pass through the sim

sst --interactive-start=0 --add-lib-path=$SST_COMPONENT_BASE/tests/components/CaptCrunch/ $TEST_NAME.py <<EOF
ls
confirm false
cd c0
ls
quit
EOF

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi


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
