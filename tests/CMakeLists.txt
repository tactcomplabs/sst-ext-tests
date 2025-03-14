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
option(ENABLE_ALL_TESTS "Enable ALL testing" OFF)

# -- walk each subdirectory and individually enable them
if(ENABLE_CLI_TESTS OR ENABLE_ALL_TESTS)
  add_subdirectory(cli)
endif()

# EOF
