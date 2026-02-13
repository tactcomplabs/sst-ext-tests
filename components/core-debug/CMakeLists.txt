#
# sst-ext-tests/tests/components/core-debug CMake
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

set(DbgSST15Srcs
  omni.cc
  omni.h
  om-arrays.cc
  om-arrays.h
  om-queue.cc
  om-queue.h
  om-nested-containers.h
  om-nested-containers.cc
  om-unions.cc
  om-unions.h
  dbgsst15.cc
  dbgsst15.h
  probe.cc
  probe.h
)

add_library(dbgsst15 SHARED ${DbgSST15Srcs})
target_include_directories(dbgsst15 PUBLIC ${SST_INSTALL_DIR}/include)
install(TARGETS dbgsst15 DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
install(CODE "execute_process(COMMAND sst-register dbgsst15 dbgsst15_LIBDIR=${CMAKE_CURRENT_SOURCE_DIR})")

# EOF
