import sst
sst.setStatisticLoadLevel(4)
sst.enableAllStatisticsForAllComponents()
sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "eCaptCrunchObjMap_0-DEV.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunchobjmap.CaptCrunchObjMap") #captcrunch.CaptCrunch")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "10000",
  "testSuiteParam" : "0"
})
