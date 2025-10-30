import sst
sst.setStatisticLoadLevel(4)
sst.enableAllStatisticsForAllComponents()
sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "eCaptCrunchObjMap_5-DEV.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunchobjmap.CaptCrunchObjMap")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "10000",
  "testSuiteParam" : "5"
})

