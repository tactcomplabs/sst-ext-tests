# Copyright 2009-2025 NTESS. Under the terms
# of Contract DE-NA0003525 with NTESS, the U.S.
# Government retains certain rights in this software.
#
# Copyright (c) 2009-2025, NTESS
# All rights reserved.
#
# This file is part of the SST software package. For license
# information, see the LICENSE file in the top level directory of the
# distribution.
#EXT_TEST TEST_FILE_PARAM DEV
#EXT_TEST TEST_FILE_DESC "Tests the basic serialization with UNORDERED CONTAINERS types and checkpointing"
#EXT_TEST DEP "coreTestElement.coreTestSerialization"
import sst
import sys

sst.setProgramOption("stop-at", "1us");

#test = sys.argv[1]
# -- test types
# -- -- pod
# -- -- pod_ptr
# -- -- ordered_containers
# -- -- unordered_containers
# -- -- map_to_vector
# -- -- pointer_tracking
# -- -- handler
# -- -- componentinfo
# -- -- atomic
test = "unordered_containers"

comp = sst.Component("Component0", "coreTestElement.coreTestSerialization")
comp.addParam("test", test)
