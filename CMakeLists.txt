#
# sst-ext-tests top-level CMake
#
# Copyright (C) 2017-2024 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

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
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-major-version.sh
                OUTPUT_VARIABLE SST_MAJOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/sst-minor-version.sh
                OUTPUT_VARIABLE SST_MINOR_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "SST MAJOR VERSION=${SST_MAJOR_VERSION}")

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

#-- Subdirectories
#add_subdirectory(sst-bench)

# EOF
