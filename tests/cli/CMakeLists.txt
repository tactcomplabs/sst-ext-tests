#
# sst-ext-tests/tests/cli CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#

set(TEST_FILE_EXT "sh")
set(passRegex "PASS")

#-- SST Enabled Test Versions
file(GLOB TEST_SRCS_TARGET_VER RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-MIN${SST_VERSION}.${TEST_FILE_EXT})
foreach(testSrc ${TEST_SRCS_TARGET_VER})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WLE)

  # Add the tests for execution
  add_test(NAME ${testName}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ./${testSrc})
  set_property(TEST ${testName} PROPERTY LABELS "${SST_VERSION}")
endforeach(testSrc)

#-- SST Enabled Minimum Test Versions
foreach(testVer ${SST_VER_LIST})
  message(STATUS "building tests for SST VERSION ${testVer}")
  file(GLOB TEST_SRCS_VER RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-${testVer}.${TEST_FILE_EXT})
  foreach(testSrc ${TEST_SRCS_VER})
    # Extract the file name
    get_filename_component(testName ${testSrc} NAME_WLE)

    # Add the tests for execution
    add_test(NAME ${testName}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND ./${testSrc})
    set_property(TEST ${testName} PROPERTY LABELS "${testVer}")
  endforeach(testSrc)
endforeach(testVer)

#-- SST All Version Tests
file(GLOB TEST_SRCS_ALL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-ALL.${TEST_FILE_EXT})
foreach(testSrc ${TEST_SRCS_ALL})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WE)

  # Add the tests for execution
  add_test(NAME ${testName}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ./${testSrc})
  set_property(TEST ${testName} PROPERTY LABELS "ALL")
endforeach(testSrc)

# EOF
