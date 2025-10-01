#
# sst-ext-tests/tests/components/CaptCrunch CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#


set(CaptCrunchObjMapSrcs
  CaptCrunchObjMap.cc
  CaptCrunchObjMap.h
)

add_library(captcrunchobjmap SHARED ${CaptCrunchObjMapSrcs})
target_include_directories(captcrunchobjmap PUBLIC ${SST_INSTALL_DIR}/include)
install(TARGETS captcrunchobjmap DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
install(CODE "execute_process(COMMAND sst-register captcrunchobjmap captcrunchobjmap_LIBDIR=${CMAKE_CURRENT_SOURCE_DIR})")

# EOF
