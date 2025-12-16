#
# sst-ext-tests/tests/components CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

#-- Additional Include Paths
include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# -- add the component directories.
if ( (${SST_VERSION} STREQUAL "DEV") OR (${SST_VERSION} VERSION_GREATER_EQUAL "15.1") )
    message(STATUS "Adding CaptCrunch SST Component")
    add_subdirectory(CaptCrunch)
else()
    message(STATUS "CaptCrunch is supported only for sst 15.0 or newer")
endif()

if ( (${SST_VERSION} STREQUAL "DEV") OR (${SST_VERSION} VERSION_GREATER_EQUAL "15.1") )
    message(STATUS "Adding core-debug SST Components")
    add_subdirectory(core-debug)
else()
    message(STATUS "core-debug component is supported only for sst 15.1 or newer")
endif()

# EOF
