# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#

# Usage: sst --interactive-start=0 debug.py

import sst
# sst.setStatisticLoadLevel(4)
# sst.enableAllStatisticsForAllComponents()
# sst.setStatisticOutput("sst.statOutputCSV", { "filepath" : "$TEST_NAME.csv", "separator" : "," } )

c0 = sst.Component("c0", "captcrunch.CaptCrunch")
c0.addParams({
  "numStats" : "100",
  "numClocks" : "10000"
})
