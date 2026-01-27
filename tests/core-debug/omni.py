#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#
# omni.py
# Object Map Noir Inspector

import argparse
import sst

parser = argparse.ArgumentParser(description="Object Map Noir Inspector")
parser.add_argument("--verbose",              type=int,   help="verbosity", default=2)
parser.add_argument("--function0",            type=str,   help="function0 subcomponent (e.g. dbgsst15.OMQueue)", required=True)
parser.add_argument("--function1",            type=str,   help="function1 subcomponent", required=False)

args = parser.parse_args()

# single component
class Simple():
  def __init__(self):

    self.c0 =  sst.Component(f"c0",  "dbgsst15.OMSimpleComponent")
    self.c0.addParams({
      "verbose" : args.verbose,
      "primary" : 1
      })
    self.c0f0 = self.c0.setSubComponent( "function0", args.function0 )
    if args.function1:
      self.c0f1 = self.c0.setSubComponent( "function1", args.function1 )

# 2 components sharing a link
class Simple2():
  def __init__(self):

    # components
    self.c0 =  sst.Component(f"c0",  "dbgsst15.OMSimpleComponent")
    self.c1 =  sst.Component(f"c1",  "dbgsst15.OMSimpleComponent")

    # parameters
    self.c0.addParams({
      "verbose" : args.verbose,
      "primary" : 1
      })
    self.c1.addParams({"verbose" : args.verbose})
    
    # slots
    self.c0f0 = self.c0.setSubComponent( "function0", "args.function0")
    self.c1f0 = self.c1.setSubComponent( "function0", "args.function0")
    if args.function1:
      self.c0f1 = self.c1.setSubComponent( "function1", "args.function1")
      self.c1f1 = self.c1.setSubComponent( "function0", "args.function1")

    # links
    self.link0 = sst.Link("f0")
    self.link0.connect( (self.c0, "port0", "10ns"), (self.c1, "port0", "10ns") ) 

# Instantiation
simple = Simple();

#EOF
