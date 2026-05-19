#
# sst-ext-tests/tests CMake
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#

# -- make test options visible to cmake
option(ENABLE_NEW_TESTS "Enable NEW tests for sst-core feature branches" OFF)
option(ENABLE_ALL_TESTS "Enable ALL production tests" OFF)
option(ENABLE_CLI_TESTS "Enable CLI testing" OFF)
option(ENABLE_JSON_TESTS "Enable sequential JSON testing" OFF)

option(ENABLE_DEBUG_TESTS "Interactive debug mode tests")
option(ENABLE_RTACTION_TESTS "Enable Realtime Action testing" OFF)
option(ENABLE_CAPTCRUNCH_TESTS "Enable Captain Crunch testing" OFF)
option(ENABLE_REMAP_TESTS "Enable checkpoint remap on restart testing" OFF)

# -- purely optional tests
option(ENABLE_CORE_CHKPT_TESTS "Purely optional: Enable sst-core checkpointing tests" OFF)
option(ENABLE_MPI_TESTS "Purely optional: Enable multi-rank MPI testing" OFF)
option(ENABLE_CORE_RESTART_PLATFORM_TESTS "Purely optional: Enable restart test from incorrect OS/Arch" OFF)

if (ENABLE_ALL_TESTS)
  set(ENABLE_CLI_TESTS ON CACHE BOOL "Enable CLI testing" FORCE)
  set(ENABLE_DEBUG_TESTS ON CACHE BOOL "Interactive debug mode tests" FORCE)
  set(ENABLE_RTACTION_TESTS ON CACHE BOOL "Enable Realtime Action testing" FORCE)
  set(ENABLE_CAPTCRUNCH_TESTS ON CACHE BOOL "Enable Captain Crunch testing" FORCE)
  set(ENABLE_JSON_TESTS ON CACHE BOOL "Enable sequential JSON testing" FORCE)
  set(ENABLE_REMAP_TESTS ON CACHE BOOL "Enable checkpoint remap on restart testing" FORCE)
endif()

# -- walk each subdirectory and individually enable them
if(ENABLE_CLI_TESTS)
  add_subdirectory(cli)
endif()

if(ENABLE_JSON_TESTS)
  add_subdirectory(json_seq)
endif()

if(ENABLE_RTACTION_TESTS)
  add_subdirectory(rt_action)
endif()

if(ENABLE_CAPTCRUNCH_TESTS)
  add_subdirectory(CaptCrunch)
endif()

if(ENABLE_DEBUG_TESTS)
  add_subdirectory(debug-console)
  if(SST_MPI_OK)
    add_subdirectory(debug-console-mpi)
  endif()
endif()

if (ENABLE_REMAP_TESTS)
  add_subdirectory(remap)
  if(SST_MPI_OK)
    add_subdirectory(remap-mpi)
  endif()
endif()

# -- strictly optional tests
if(ENABLE_CORE_CHKPT_TESTS)
  add_subdirectory(core-chkpt)
endif()

if(ENABLE_MPI_TESTS)
  if(MPIEXEC_EXECUTABLE)
    add_subdirectory(mpi)
    # -- Enable the parallel json tests as they require MPI
    add_subdirectory(json_parallel)
  else()
    message(FATAL_ERROR "Could not discover `mpirun` or `mpiexec`. Cannot enable MPI tests")
  endif()
endif()

if(ENABLE_CORE_RESTART_PLATFORM_TESTS)
  add_subdirectory(core-restart-platform)
endif()

# EOF
