#
# sst-ext-tests/tests CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# -- walk each subdirectory and individually enable them
if(ENABLE_CLI_TESTS)
  add_subdirectory(cli)
endif()

#-- if all tests are enabled, add all the directories
if(ENABLE_ALL_TESTS)
  add_subdirectory(cli)
endif()

# EOF
