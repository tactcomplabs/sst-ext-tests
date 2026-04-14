#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#
# dbg_loop101.py
#

import argparse
import sst

parser = argparse.ArgumentParser(description="dbg_loop101.py")
parser.add_argument("--clocks", type=int, help="minimum clock cycles to run", default=1000000)
parser.add_argument("--numComps", type=int, help="number of components to instantiate", default=101)
parser.add_argument("--probeStartCycle", type=int, help="cycle to initiate debug probe. 0=Off", default=0)
parser.add_argument("--probeEndCycle", type=int, help="cycle to end debug probe. 0=Never", default=0)
parser.add_argument("--probeBufferSize", type=int, help="number of records in circular buffer", default=16)
parser.add_argument("--probePostDelay", type=int, help="number of events to capture after trigger event", default=8)
parser.add_argument("--probePort", type=int, help="sst probe starting socket. 0=None", default=0 )
parser.add_argument("--verbose", type=int, help="verbosity. 5=send/recv", default=1)
# 0b0100_0000 : 0x40 : 64 Every checkpoint
# 0b0010_0000 : 0x20 : 32 Every checkpoint when probe is active
# 0b0001_0000 : 0x10 : 16 Every checkpoint sync state change
# 0b0000_0100 : 0x04 : 04 Every probe sample
# 0b0000_0010 : 0x02 : 02 Every probe sample from trigger onward
# 0b0000_0001 : 0x01 : 01 Every probe state change,
parser.add_argument("--cliControl", type=int, help="event types on which to break into interactive mode"
" [64 Every checkpoint]"
" [32 Every checkpoint when probe is active]"
" [16 Every checkpoint sync state change]"
" [04 Every probe sample]"
" [02 Every probe sample from trigger onward]"
" [01 Every probe state change]", default=0)

args = parser.parse_args()
print("debug probe demo configuration:")
for arg in vars(args):
  print("\t", arg, " = ", getattr(args, arg))

# Component custom trace controls
TRACE_SEND = 1
TRACE_RECV = 2

MIN_DATA = 1
MAX_DATA = 100

CLOCKS = args.clocks
NUM_COMPS = args.numComps
print(f"Instantiating {NUM_COMPS} components")

components = [None] * NUM_COMPS
frequency = 1.0
FREQ_CHANGE = 0.1

for i in range(NUM_COMPS):
  components[i] = sst.Component(f"cp{i}", "dbgsst15.DbgSST15")
  if i%2 != 0:
      TRACE_MODE=TRACE_RECV
  else:
      TRACE_MODE=TRACE_SEND
  
  components[i].addParams({
    "verbose" : args.verbose,
    "selfCheck" : 1,
    "numPorts" : 2,
    "minData" : MIN_DATA,
    "maxData" : MAX_DATA,
    "clockDelay" : 100,
    "clocks" : CLOCKS,
    "rngSeed" : 1223,
    "clockFreq" : f"{frequency}Ghz",
    # common probe controls
    #"probeMode" : 1,
    "probeStartCycle" : args.probeStartCycle,
    "probeEndCycle"   : args.probeEndCycle,
    "probeBufferSize" : args.probeBufferSize,
    "probePostDelay"  : args.probePostDelay,
    "probePort"       : args.probePort,
    "cliControl"      : args.cliControl,
    # component specific probe controls
    "traceMode"       : TRACE_MODE,
  })
  frequency += FREQ_CHANGE

# pairs are linked but indendepent of each other
links = [None] * NUM_COMPS
for i in range(NUM_COMPS-1):
  links[i] = sst.Link(f"link{i}")
  links[i].connect( (components[i], "port0", "1us"), (components[i+1], "port1", "1us") )
# finally connect back to beginning
links[NUM_COMPS-1] = sst.Link(f"link{i}")
links[NUM_COMPS-1].connect( (components[NUM_COMPS-1], "port0", "1us"), (components[0], "port1", "1us") )

# EOF
