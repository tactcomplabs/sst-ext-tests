#
# Copyright (C) 2017-2024 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#
# dbgsst15.py
#

import argparse
import sst

parser = argparse.ArgumentParser(description="realtime action test helper")
parser.add_argument("--sleep", type=int, help="time in seconds to sleep on 1st clock [0]", default=0)
parser.add_argument("--clocks", type=int, help="number of clocks to run [1000000]", default=1000000)
parser.add_argument("--verbose", type=int, help="verbosity. 5=send/recv [0]", default=0)

args = parser.parse_args()
print("realtime action test helper:")
for arg in vars(args):
  print("\t", arg, " = ", getattr(args, arg))

# Component custom trace controls
TRACE_SEND = 1
TRACE_RECV = 2

MIN_DATA = 1
MAX_DATA = 1000

cp0 = sst.Component("cp0", "dbgsst15.DbgSST15")
cp0.addParams({
  "verbose" : args.verbose,
  "numPorts" : 1,
  "minData" : MIN_DATA,
  "maxData" : MAX_DATA,
  "clockDelay" : 100,
  "clocks" : args.clocks,
  "rngSeed" : 1223,
  "clockFreq" : "1Ghz",
})

cp1 = sst.Component("cp1", "dbgsst15.DbgSST15")
cp1.addParams({
  "verbose" : args.verbose,
  "numPorts" : 1,
  "minData" : MIN_DATA,
  "maxData" : MAX_DATA,
  "clockDelay" : 100,
  "clocks" : args.clocks,
})

link0 = sst.Link("link0")
link0.connect( (cp0, "port0", "1us"), (cp1, "port0", "1us") )

# EOF
