#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_MAXVER DEV
#EXT_TEST TEST_FILE_DESC "sst-test-core parallel json tests"
#EXT_TEST TIMEOUT 120
#EXT_TEST DEP "coreTestElement.SubComponentLoader coreTestElement.message_mesh.enclosing_component"

MPIEXEC="$1"
shift
MPIARGS="$@"

# Parallel / serial load
sst -n 4 test_MessageMesh_6_6_1r4t.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_1r4t.json] : $retVal"
  exit $retVal
fi

$MPIEXEC $MPIARGS -np 2 sst -n 3 test_MessageMesh_6_6_2r3t.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_2r3t.json] : $retVal"
  exit $retVal
fi

$MPIEXEC $MPIARGS -np 3 sst test_MessageMesh_6_6_3r1t.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_3r1t.json] : $retVal"
  exit $retVal
fi

sst -n 4 --parallel-load="MULTI" test_MessageMesh_6_6_1r4t_paraload.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_1r4t_paraload.json] : $retVal"
  exit $retVal
fi

$MPIEXEC $MPIARGS -np 2 sst -n 3 --parallel-load="MULTI" test_MessageMesh_6_6_2r3t_paraload.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_2r3t_paraload.json] : $retVal"
  exit $retVal
fi

$MPIEXEC $MPIARGS -np 3 sst --parallel-load="MULTI" test_MessageMesh_6_6_3r1t_paraload.json
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR [test_MessageMesh_6_6_3r1t_paraload.json] : $retVal"
  exit $retVal
fi

# EOF
