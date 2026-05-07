#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_MAXVER 16.0
#EXT_TEST TEST_FILE_DESC "sst-test-core sequential tests"
#EXT_TEST TIMEOUT 120
#EXT_TEST DEP "coreTestElement.SubComponentLoader coreTestElement.message_mesh.enclosing_component"

json_files="test_Component_serial.json test_MessageMesh_6_6_serial.json test_ParamComponent_serial.json test_PortModule_pass_recv_serial.json test_PortModule_randomdrop_send_serial.json test_PortModule_drop_recv_sub_serial.json test_PortModule_modify_send_sub_serial.json test_StatisticsComponent_basic_serial.json test_sc_2a_serial.json test_sc_2u2a_serial.json test_sc_2u2u_serial.json test_sc_2ua_serial.json test_sc_2u_serial.json test_sc_2uu_serial.json test_sc_a_serial.json test_sc_u2a_serial.json test_sc_u2u_serial.json test_sc_ua_serial.json test_sc_u_serial.json test_sc_uu_serial.json"

for j in $json_files; do
  sst --run-mode=init $j
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "ERROR [$j] : $retVal"
    exit $retVal
  fi
done;

echo "PASS"
exit 0
