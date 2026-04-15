#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "8 rank checkpointed to 8 rank restart"
#EXT_TEST TIMEOUT 120

./rt2rt.bash 8 1 8 1
