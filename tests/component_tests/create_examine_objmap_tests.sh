#!/usr/bin/env bash
echo $CWD

for i in {0..20}; do
TEST_NAME=eCaptCrunchObjMap_$i-DEV
rm -Rf $TEST_NAME.py
cat > $TEST_NAME.py << EOL
import sst
sst.setStatisticLoadLevel(4)
sst.enableAllStatisticsForAllComponents()
sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "$TEST_NAME.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunchobjmap.CaptCrunchObjMap")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "10000",
  "testSuiteParam" : "$i"
})
EOL
done
