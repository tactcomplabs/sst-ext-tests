#
# sst-ext-tests/tests/components/CaptCrunch CMake
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

set(CaptCrunchSrcs
  CaptCrunch.cc
  CaptCrunch.h
)

add_library(captcrunch SHARED ${CaptCrunchSrcs})
target_include_directories(captcrunch PUBLIC ${SST_INSTALL_DIR}/include)
install(TARGETS captcrunch DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
install(CODE "execute_process(COMMAND sst-register captcrunch captcrunch_LIBDIR=${CMAKE_CURRENT_SOURCE_DIR})")

# EOF
