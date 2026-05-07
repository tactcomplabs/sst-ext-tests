#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "Tests to ensure that existing checkpoints fail to restart on the wrong architecture"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

SST_PLAT_EXE="../../scripts/sst-platform"
SST_PLAT=`$SST_PLAT_EXE --package`
SST_ARCH=`$SST_PLAT_EXE --arch`
SST_OS=`$SST_PLAT_EXE --os`


if [[ "$SST_ARCH" == "x86_64" ]]; then
  # run the AArch64 tests
  sst ./refFiles/chkpt-ARM64-OS_MACOS/checkpoint/checkpoint_1_10000000/checkpoint_1_10000000.sstcpt
  if [ $retVal -eq 0 ]; then
    echo "ERROR : Test should fail : $retVal"
    exit 42
  fi
else
  # run the x86_64 tests
  sst ./refFiles/chkpt-x86_64-OS_Linux/checkpoint/checkpoint_1_10000000/checkpoint_1_10000000.sstcpt
  if [ $retVal -eq 0 ]; then
    echo "ERROR : Test should fail : $retVal"
    exit 42
  fi
fi

if [[ "$SST_OS" == "OS_LINUX" ]]; then
  # run the OS_MACOS tests
  sst ./refFiles/chkpt-ARM64-OS_MACOS/checkpoint/checkpoint_1_10000000/checkpoint_1_10000000.sstcpt
  if [ $retVal -eq 0 ]; then
    echo "ERROR : Test should fail : $retVal"
    exit 42
  fi
else
  # run the OS_LINUX tests
  sst ./refFiles/chkpt-x86_64-OS_LINUX/checkpoint/checkpoint_1_10000000/checkpoint_1_10000000.sstcpt
  if [ $retVal -eq 0 ]; then
    echo "ERROR : Test should fail : $retVal"
    exit 42
  fi
fi

if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
