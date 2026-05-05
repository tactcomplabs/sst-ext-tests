#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "5 thread checkpointed to 1 thread restart"
#EXT_TEST TIMEOUT 1000

./thread2thread.bash 5 1
