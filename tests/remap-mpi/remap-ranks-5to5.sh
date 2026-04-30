#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "5 rank checkpointed to 5 rank restart"
#EXT_TEST TIMEOUT 120

./rt2rt.bash 5 1 5 1
