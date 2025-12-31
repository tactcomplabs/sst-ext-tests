#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "Tests to ensure that existing checkpoints can be restarted on the correct architecture"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

SST_PLAT_EXE="../../scripts/sst-platform"
SST_PLAT=`$SST_PLAT_EXE --package`
SST_ARCH=`$SST_PLAT_EXE --arch`
SST_OS=`$SST_PLAT_EXE --os`

sst ./refFiles/chkpt-$SST_ARCH-$SST_OS/checkpoint/checkpoint_1_10000000/checkpoint_1_10000000.sstcpt

if [ $retVal -ne 0 ]; then
  echo "ERROR : $retVal"
  exit $retVal
fi
echo "PASS"
exit 0
