#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1.0
#EXT_TEST TEST_FILE_DESC "2 thread checkpointed to 2 thread restart"
#EXT_TEST TIMEOUT 120

./thread2thread.bash 2 2
