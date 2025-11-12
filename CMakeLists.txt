#
# sst-ext-tests top-level CMake
#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# ---------------------------------------------------
# string_contains_number
# ---------------------------------------------------
function(string_contains_number str result)
  string(REGEX MATCH "[0-9]" has_number "${str}")
  if(has_number)
    set(${result} TRUE PARENT_SCOPE)
  else()
    set(${result} FALSE PARENT_SCOPE)
  endif()
endfunction()

# ---------------------------------------------------
# main
# ---------------------------------------------------
#-- Prevent in-source builds
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Minimum required version of CMake and project information
cmake_minimum_required(VERSION 3.19)
project(sst-ext-tests CXX)

# SST Configuration Sanity Check
find_program(SST sst)

find_program(SST_CONFIG sst-config)
if(NOT SST OR NOT SST_CONFIG)
  message(FATAL_ERROR "No SST binary or sst-config binary found in path")
endif()

# SST Environment Derivation
execute_process(COMMAND sst-config --prefix
                OUTPUT_VARIABLE SST_INSTALL_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(SST_INCLUDE_DIR "${SST_INSTALL_DIR}/include")
if(NOT (EXISTS "${SST_INSTALL_DIR}"))
  message(FATAL_ERROR " SST_INSTALL_DIR (${SST_INSTALL_DIR}) is invalid.")
endif()
include_directories(SST_SRC ${SST_INSTALL_DIR})

# SST Version found in path
execute_process(COMMAND sst --version
                OUTPUT_VARIABLE SST_VERSION_STRING
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "${SST_VERSION_STRING}")

# Allow override using -DSST_VERSION=n
if (DEFINED SST_VERSION)  
  message(STATUS "SST_VERSION test selection override: ${SST_VERSION}")
endif()

execute_process(COMMAND sst-config --CXX
                OUTPUT_VARIABLE CXX
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND sst-config --ELEMENT_CXXFLAGS
                OUTPUT_VARIABLE SST_CXXFLAGS
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND sst-config --ELEMENT_LDFLAGS
                OUTPUT_VARIABLE SST_LDFLAGS
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND sst-config SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_LIBDIR
                OUTPUT_VARIABLE SST_ELEMENT_LIBRARY_LIBDIR
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-major-version.sh ${SST_VERSION}
                OUTPUT_VARIABLE SST_MAJOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-minor-version.sh ${SST_VERSION}
                OUTPUT_VARIABLE SST_MINOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)

string_contains_number("${SST_MAJOR_VERSION}" contains_num)
if(NOT contains_num)
  set(SST_MAJOR_VERSION "DEV")
  set(SST_MINOR_VERSION "DEV")
  execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-git-hash.sh
                  OUTPUT_VARIABLE SST_GIT_HASH
                  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  message(STATUS "SST GIT HASH=${SST_GIT_HASH}")
endif()

#-- Create version variables (will rewrite command line provided SST_VERSION)
message(STATUS "SST MAJOR VERSION=${SST_MAJOR_VERSION}")
message(STATUS "SST MINOR VERSION=${SST_MINOR_VERSION}")
if ("${SST_MAJOR_VERSION}" STREQUAL "DEV")
  set(SST_VERSION "DEV")
else()
 string(CONCAT SST_VERSION  ${SST_MAJOR_VERSION} "." ${SST_MINOR_VERSION})
endif()
message(STATUS "SST FULL VERSION=${SST_VERSION}")


#-- MPI Options
find_package(MPI)
if(MPIEXEC_EXECUTABLE)
  message(STATUS "MPI RUN COMMAND=${MPIEXEC_EXECUTABLE}")
endif()

#-- setup the component build directory
set(ENV{SST_COMPONENT_BASE} "${CMAKE_BINARY_DIR}")
# set(SST_COMPONENT_BASE "${CMAKE_CURRENT_SOURCE_DIR}/tests/components")
message(STATUS "SST-EXT-TESTS ENV{SST_COMPONENT_BASE}=$ENV{SST_COMPONENT_BASE}")

#-- Compiler Options
# Compiler Options
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  set(WERROR_FLAG "")
  set(FP_MODE_FLAG "-ffp-model=strict")
else()
  set(WERROR_FLAG "-Werror")
  set(FP_MODE_FLAG "-frounding-math")
endif()

set(LDFLAGS "${SST_LDFLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++17 ${FP_MODE_FLAG} -O2 -Wall -Wextra ${WERROR_FLAG} -Wvla -Wuninitialized -Wfloat-conversion -Wdouble-promotion -Wno-unused-parameter -Wno-deprecated-declarations ${CMAKE_CXX_FLAGS} -I./ ${LDFLAGS}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -std=c++17 ${FP_MODE_FLAG} -g -pg -O0 -Wall -Wextra ${WERROR_FLAG} -Wvla -Wuninitialized -Wfloat-conversion -Wdouble-promotion -Wno-unused-parameter -Wno-deprecated-declarations -I./ ${LDFLAGS}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -Wall")

set(EXT_TEST_LIST_COMMAND "${CMAKE_SOURCE_DIR}/scripts/gen-testlist.sh")
set(EXT_TEST_DEP_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-dep.sh")
set(EXT_TEST_TIMEOUT_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-timeout.sh")
set(EXT_TEST_MPIARGS_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-mpiargs.sh")

#-- Setup supported version arrays
set(SST_TMP_VER_LIST "13.0" "13.1" "14.0" "14.1" "15.0" "15.1")
set(SST_VER_LIST "DEV")

if(NOT "${SST_MAJOR_VERSION}" STREQUAL "DEV")
  foreach(VERSION ${SST_TMP_VER_LIST})
    if(NOT ${VERSION} VERSION_LESS ${SST_VERSION})
      list(APPEND SST_VER_LIST ${VERSION})
    endif()
  endforeach()
endif()

#-- Add testing
enable_testing()

#-- Custom Commands
add_custom_target(uninstall COMMAND
  "${CMAKE_CURRENT_SOURCE_DIR}/scripts/uninstall.sh")

#-- Subdirectories
add_subdirectory(tests)

# EOF
