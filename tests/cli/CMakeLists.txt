#
# sst-ext-tests/tests/cli CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#

file(GLOB TEST_SRCS_ALL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-ALL.sh)

set (passRegex "PASS")

foreach(testSrc ${TEST_SRCS_ALL})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WE)

  # Add the tests for execution
  add_test(NAME ${testName}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ./${testSrc})
endforeach(testSrc)

# EOF
