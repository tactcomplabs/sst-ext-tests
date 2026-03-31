#
# sst-ext-tests top-level CMake
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
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
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
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

# SST Flags
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

# Underscore prefix convention indicates private scope.
# Use the resolved SST_VERSION in other other cmake files
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-major-version.sh ${SST_VERSION}
                OUTPUT_VARIABLE _SST_MAJOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-minor-version.sh ${SST_VERSION}
                OUTPUT_VARIABLE _SST_MINOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)

string_contains_number("${_SST_MAJOR_VERSION}" contains_num)
if(NOT contains_num)
  set(_SST_MAJOR_VERSION "DEV")
  set(_SST_MINOR_VERSION "DEV")
  execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-git-hash.sh
                  OUTPUT_VARIABLE SST_GIT_HASH
                  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  message(STATUS "SST GIT HASH=${SST_GIT_HASH}")
endif()

#-- Create version variables (will rewrite command line provided SST_VERSION)
message(STATUS "SST MAJOR VERSION=${_SST_MAJOR_VERSION}")
message(STATUS "SST MINOR VERSION=${_SST_MINOR_VERSION}")

# Allow override using -DSST_VERSION=n
# Important: subdirectories should only use this resolved version
if (DEFINED SST_VERSION)
  message(STATUS "SST_VERSION test selection override: ${SST_VERSION}")
elseif ("${_SST_MAJOR_VERSION}" STREQUAL "DEV")
  set(SST_VERSION "DEV")
else()
 string(CONCAT SST_VERSION  ${_SST_MAJOR_VERSION} "." ${_SST_MINOR_VERSION})
endif()
message(STATUS "RESOLVED SST VERSION=${SST_VERSION}")


#-- MPI Options
find_package(MPI)
if(MPIEXEC_EXECUTABLE)
  message(STATUS "MPI RUN COMMAND=${MPIEXEC_EXECUTABLE}")
endif()
execute_process(COMMAND sst-config --MPICC
                OUTPUT_VARIABLE SST_MPICC
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "SST_MPICC=${SST_MPICC}")

# Allow testing using mpirun with sst compiled without mpi
if (MPIEXEC_EXECUTABLE AND  ${SST_MPICC} MATCHES ".*mpi.*" )
  set(SST_MPI_OK 1)
else()
  set(SST_MPI_OK 0)
endif()
message(STATUS "SST_MPI_OK=${SST_MPI_OK}")

#-- setup the component build directory
set(ENV{SST_COMPONENT_BASE} "${CMAKE_BINARY_DIR}/components")
message(STATUS "SST-EXT-TESTS ENV{SST_COMPONENT_BASE}=$ENV{SST_COMPONENT_BASE}")

#-- Compiler Options
option(SST_WERROR "Compile with warnings as errors" ON)
if (SST_WERROR)
  set(WERROR_FLAG "-Werror")
endif()

option(SST_ASAN "Compile using address sanitizer" OFF)
if (SST_ASAN)
  set (SANITIZE_FLAG "-fsanitize=address -fno-omit-frame-pointer")
endif()

if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  set(FP_MODE_FLAG "-ffp-model=strict -frounding-math -ftrapping-math")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-command-line-argument")
else()
  set(FP_MODE_FLAG "-frounding-math -ftrapping-math")
  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wmissing-format-attribute -Wsuggest-final-methods -Wsuggest-final-types -Wvolatile")
  # -Wvolatile not recognized on sst-core-rocky88-gcc85-openmpi4.6
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wmissing-format-attribute -Wsuggest-final-methods -Wsuggest-final-types")
endif()

option(ENABLE_VALGRIND "Enable testing with Valgrind" OFF)
if (ENABLE_VALGRIND)
  message(STATUS "Valgrind test execution enabled.  Increasing test timeout by 10X")
  set(SST_VALGRIND ON)
  find_package(Valgrind)
  if (VALGRIND_FOUND)
    message(STATUS "Enabling Valgrind tests using: ${Valgrind_EXECUTABLE}")
  else()
    message(STATUS "Valgrind not found.") 
  endif()
endif()

# -- Prefer modular components over using version specific compile options
if ( (${SST_VERSION} STREQUAL "DEV") OR (${SST_VERSION} VERSION_GREATER "15.1") )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DSST_VER_GT_15_1")
endif()

# -- setup override files
find_program(SST NAMES "sst")
find_program(SSTREGISTER NAMES "sst-register")
find_program(SSTCONFIG NAMES "sst-config")
find_program(SSTINFO NAMES "sst-info")
set(SST_PLATFORM "${CMAKE_BINARY_DIR}/utils/sst-platform/sst-platform")
configure_file( "${CMAKE_SOURCE_DIR}/scripts/sst.in"
                "${CMAKE_SOURCE_DIR}/scripts/sst"
                @ONLY)
configure_file( "${CMAKE_SOURCE_DIR}/scripts/sst-register.in"
                "${CMAKE_SOURCE_DIR}/scripts/sst-register"
                @ONLY)
configure_file( "${CMAKE_SOURCE_DIR}/scripts/sst-config.in"
                "${CMAKE_SOURCE_DIR}/scripts/sst-config"
                @ONLY)
configure_file( "${CMAKE_SOURCE_DIR}/scripts/sst-info.in"
                "${CMAKE_SOURCE_DIR}/scripts/sst-info"
                @ONLY)
configure_file( "${CMAKE_SOURCE_DIR}/scripts/valgrind_ctest.in"
                "${CMAKE_SOURCE_DIR}/scripts/valgrind_ctest"
                @ONLY)
configure_file( "${CMAKE_SOURCE_DIR}/scripts/sst-platform.in"
                "${CMAKE_SOURCE_DIR}/scripts/sst-platform"
                @ONLY)

set(LDFLAGS "${SST_LDFLAGS}")

set(CMAKE_CXX_FLAGS "-std=c++17 ${FP_MODE_FLAG} -O2 -Wall -Wextra -Wsuggest-override -Wvla -Wuninitialized -Wfloat-conversion -Wdouble-promotion -Wno-unused-parameter -Wno-deprecated-declarations -Wsign-conversion -Wconversion -Wno-unused-parameter -Wno-deprecated-declarations -Wno-macro-redefined ${WERROR_FLAG} ${SANITIZE_FLAG} ${CMAKE_CXX_FLAGS} -I./ ${LDFLAGS}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -Wall")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -Wall")

set(EXT_TEST_LIST_COMMAND "${CMAKE_SOURCE_DIR}/scripts/gen-testlist.sh")
set(EXT_TEST_DEP_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-dep.sh")
set(EXT_TEST_TIMEOUT_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-timeout.sh")
set(EXT_TEST_MPIARGS_COMMAND "${CMAKE_SOURCE_DIR}/scripts/test-mpiargs.sh")

#-- Setup supported version arrays
set(SST_TMP_VER_LIST "13.0" "13.1" "14.0" "14.1" "15.0" "15.1")
set(SST_VER_LIST "DEV")

if(NOT "${_SST_MAJOR_VERSION}" STREQUAL "DEV")
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

#-- SST Utilities
add_subdirectory(utils)

#-- SST Component Libraries
add_subdirectory(components)

#-- Subdirectories
add_subdirectory(tests)

# EOF
