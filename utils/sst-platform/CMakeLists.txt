#
# sst-ext-tests/utils/sst-platform CMake
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

set(sstPlatSrcs
  sst-platform.cc
)

add_executable(sst-platform ${sstPlatSrcs})
target_include_directories(sst-platform PUBLIC ${SST_INSTALL_DIR}/include)
set(CMAKE_CXX_FLAGS "-O3")
install(TARGETS sst-platform DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})

# EOF
