#!/bin/bash
#EXT_TEST TEST_FILE_PARAM MIN14.1
#EXT_TEST TEST_FILE_DESC "Tests CaptCrunch simple data integrity"

cat > CaptCrunch_Simple1-MIN14.1.py << EOL
import sst
sst.setStatisticLoadLevel(4)
sst.enableAllStatisticsForAllComponents()
sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "CaptCrunch_Simple1-MIN14.1.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunch.CaptCrunch")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "1000000"
})
EOL

sst --checkpoint-period=10ns --add-lib-path=${CMAKE_BINARY_DIR}/tests/components/CaptCrunch/ CaptCrunch_Simple1-MIN14.1.py

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
#rm CaptCrunch_Simple1-MIN14.1.py
exit 0
