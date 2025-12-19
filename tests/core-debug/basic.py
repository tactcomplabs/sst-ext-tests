#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#
# basic.py
#

import argparse
import sst

parser = argparse.ArgumentParser(description="basic")
parser.add_argument("--verbose",              type=int,   help="verbosity", default=2)

args = parser.parse_args()

# single component
class Simple():
  def __init__(self):

    self.c0 =  sst.Component(f"c0",  "dbgsst15.OMSimpleComponent")
    self.c0.addParams({
      "verbose" : args.verbose,
      "primary" : 1
      })
    self.c0f0 = self.c0.setSubComponent( "function0", "dbgsst15.OMSimpleSubComponent")

# 2 components sharing a link
class Simple2():
  def __init__(self):

    self.c0 =  sst.Component(f"c0",  "omap.OMSimpleComponent")
    self.c0.addParams({
      "verbose" : args.verbose,
      "primary" : 1
      })
    self.c0f0 = self.c0.setSubComponent( "function0", "omap.OMSimpleSubComponent")

    self.c1 =  sst.Component(f"c1",  "omap.OMSimpleComponent")
    self.c1.addParams({"verbose" : args.verbose})
    self.c1f0 = self.c1.setSubComponent( "function0", "omap.OMSimpleSubComponent")

    self.link0 = sst.Link("f0")
    self.link0.connect( (self.c0, "port0", "10ns"), (self.c1, "port0", "10ns") ) 

# Instantiation
simple = Simple();

#EOF
