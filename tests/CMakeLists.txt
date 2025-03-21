#
# sst-ext-tests/tests CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# -- make test options visible to ccmake
option(ENABLE_CLI_TESTS "Enable CLI testing" OFF)
option(ENABLE_RTACTION_TESTS "Enable Realtime Action testing" OFF)
option(ENABLE_ALL_TESTS "Enable ALL testing" OFF)

# -- add the component directory
add_subdirectory(components)


# -- walk each subdirectory and individually enable them
if(ENABLE_CLI_TESTS OR ENABLE_ALL_TESTS)
  add_subdirectory(cli)
endif()

if(ENABLE_RTACTION_TESTS OR ENABLE_ALL_TESTS)
  add_subdirectory(rt_action)
endif()

# -- strictly optional tests
if(ENABLE_CORE_CHKPT_TESTS)
  add_subdirectory(core-chkpt)
endif()

# EOF
