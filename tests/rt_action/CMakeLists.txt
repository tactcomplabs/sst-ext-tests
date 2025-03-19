#
# sst-ext-tests/tests/cli CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
#EXT_TEST TEST_FILE_EXT sh
#

set(TEST_FILE_EXT "sh")
set(passRegex "PASS")
set(timeout "60")

#-- SST Enabled Minimum Test Versions
file(GLOB TEST_SRCS_TARGET_VER RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-MIN${SST_VERSION}.${TEST_FILE_EXT})
foreach(testSrc ${TEST_SRCS_TARGET_VER})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WLE)

  execute_process(COMMAND ${EXT_TEST_DEP_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_CHECK
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
  )
  execute_process(COMMAND ${EXT_TEST_TIMEOUT_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_TIMEOUT
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
  )

  message(STATUS "Dep Check ${testSrc} = ${EXT_TEST_CHECK}")

  # Add the tests for execution
  if( "${EXT_TEST_CHECK}" STREQUAL "RUN" )
    add_test(NAME ${testName}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND ./${testSrc})
    set_property(TEST ${testName} PROPERTY LABELS "${SST_VERSION}")
    set_property(TEST ${testName} PROPERTY PASS_REGULAR_EXPRESSION "${passRegex}")
    if(NOT ${EXT_TEST_TIMEOUT} EQUAL 0)
      set_property(TEST ${testName} PROPERTY TIMEOUT ${EXT_TEST_TIMEOUT})
      message(STATUS "Runtime ${testSrc} = ${EXT_TEST_TIMEOUT}")
    else()
      set_property(TEST ${testName} PROPERTY TIMEOUT ${timeout})
    endif()
  endif()
endforeach(testSrc)

#-- SST Enabled Test Versions
foreach(testVer ${SST_VER_LIST})
  message(STATUS "building tests for SST VERSION ${testVer}")
  file(GLOB TEST_SRCS_VER RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-${testVer}.${TEST_FILE_EXT})
  foreach(testSrc ${TEST_SRCS_VER})
    # Extract the file name
    get_filename_component(testName ${testSrc} NAME_WLE)

    execute_process(COMMAND ${EXT_TEST_DEP_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                  OUTPUT_VARIABLE EXT_TEST_CHECK
                  RESULT_VARIABLE EXT_TEST_RTN
                  OUTPUT_STRIP_TRAILING_WHITESPACE
		  ERROR_QUIET
    )
    execute_process(COMMAND ${EXT_TEST_TIMEOUT_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                  OUTPUT_VARIABLE EXT_TEST_TIMEOUT
                  RESULT_VARIABLE EXT_TEST_RTN
                  OUTPUT_STRIP_TRAILING_WHITESPACE
                  ERROR_QUIET
    )

    message(STATUS "Dep Check ${testSrc} = ${EXT_TEST_CHECK}")

    # Add the tests for execution
    if( "${EXT_TEST_CHECK}" STREQUAL "RUN" )
      add_test(NAME ${testName}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ./${testSrc})
      set_property(TEST ${testName} PROPERTY LABELS "${testVer}")
      set_property(TEST ${testName} PROPERTY PASS_REGULAR_EXPRESSION "${passRegex}")
      if(NOT ${EXT_TEST_TIMEOUT} EQUAL 0)
        set_property(TEST ${testName} PROPERTY TIMEOUT ${EXT_TEST_TIMEOUT})
        message(STATUS "Runtime ${testSrc} = ${EXT_TEST_TIMEOUT}")
      else()
        set_property(TEST ${testName} PROPERTY TIMEOUT ${timeout})
      endif()
    endif()
  endforeach(testSrc)
endforeach(testVer)

#-- SST All Version Tests
file(GLOB TEST_SRCS_ALL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *-ALL.${TEST_FILE_EXT})
foreach(testSrc ${TEST_SRCS_ALL})
  # Extract the file name
  get_filename_component(testName ${testSrc} NAME_WE)

  execute_process(COMMAND ${EXT_TEST_DEP_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_CHECK
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
  )
  execute_process(COMMAND ${EXT_TEST_TIMEOUT_COMMAND} ${CMAKE_CURRENT_SOURCE_DIR}/${testSrc}
                OUTPUT_VARIABLE EXT_TEST_TIMEOUT
                RESULT_VARIABLE EXT_TEST_RTN
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
  )

  message(STATUS "Dep Check ${testSrc} = ${EXT_TEST_CHECK}")

  # Add the tests for execution
  if( "${EXT_TEST_CHECK}" STREQUAL "RUN" )
    add_test(NAME ${testName}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND ./${testSrc})
    set_property(TEST ${testName} PROPERTY LABELS "ALL")
    set_property(TEST ${testName} PROPERTY PASS_REGULAR_EXPRESSION "${passRegex}")
    if(NOT ${EXT_TEST_TIMEOUT} EQUAL 0)
      set_property(TEST ${testName} PROPERTY TIMEOUT ${EXT_TEST_TIMEOUT})
      message(STATUS "Runtime ${testSrc} = ${EXT_TEST_TIMEOUT}")
    else()
      set_property(TEST ${testName} PROPERTY TIMEOUT ${timeout})
    endif()
  endif()
endforeach(testSrc)

# EOF
