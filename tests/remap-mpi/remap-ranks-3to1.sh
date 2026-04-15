#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "3 rank checkpointed to 1 rank restart"
#EXT_TEST TIMEOUT 120

./rt2rt.bash 3 1 1 1
