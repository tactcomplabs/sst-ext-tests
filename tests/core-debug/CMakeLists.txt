#
# sst-ext-tests/tests/core-debug CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
#EXT_TEST TEST_FILE_EXT sh
#

set(TEST_FILE_EXT "sh")
set(passRegex "PASS")

if (SST_VALGRIND)
  set(timeout "600")
else()
  set(timeout "60")
endif()

#-- Test files supporting current sst version
execute_process(COMMAND ${EXT_TEST_LIST_COMMAND} ${SST_VERSION} ${ENABLE_NEW_TESTS}
                OUTPUT_VARIABLE TEST_SRCS_TARGET_VER
                RESULT_VARIABLE EXT_TEST_LIST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
#-- Convert test string to a list
string(REPLACE " " ";" TEST_SRCS_TARGET_VER ${TEST_SRCS_TARGET_VER})
message(STATUS "Included tests from ${CMAKE_CURRENT_SOURCE_DIR}: ${TEST_SRCS_TARGET_VER}")

#-- Iterate over valid tests for the current SST version
foreach(testSrc ${TEST_SRCS_TARGET_VER})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WLE)
  # Check SST component dependencies
  execute_process(COMMAND ${EXT_TEST_DEP_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_CHECK
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
  )
  message(STATUS "Dep Check ${testSrc} = ${EXT_TEST_CHECK}")

  # Get timeout setting
  execute_process(COMMAND ${EXT_TEST_TIMEOUT_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_TIMEOUT
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
  )

  if (SST_VALGRIND)
    if(${EXT_TEST_TIMEOUT} EQUAL 0)
      set(EXT_TEST_TIMEOUT ${timeout})
    else()
      math(EXPR EXT_TEST_TIMEOUT "${EXT_TEST_TIMEOUT} * 10")
    endif()
  endif()

  # Add the tests for execution
  if( "${EXT_TEST_CHECK}" STREQUAL "RUN" )
    add_test(NAME ${testName}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND ./${testSrc})
    set_property(TEST ${testName} PROPERTY LABELS "${SST_VERSION}")
    set_property(TEST ${testName} PROPERTY PASS_REGULAR_EXPRESSION "${passRegex}")
    set_property(TEST ${testName} PROPERTY ENVIRONMENT "SST_COMPONENT_BASE=$ENV{SST_COMPONENT_BASE}")
    if(NOT ${EXT_TEST_TIMEOUT} EQUAL 0)
      set_property(TEST ${testName} PROPERTY TIMEOUT ${EXT_TEST_TIMEOUT})
      message(STATUS "Runtime ${testSrc} = ${EXT_TEST_TIMEOUT}")
    else()
      set_property(TEST ${testName} PROPERTY TIMEOUT ${timeout})
    endif()
  endif()
endforeach(testSrc)

# EOF
