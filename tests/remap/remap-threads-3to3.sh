#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "3 thread checkpointed to 3 thread restart"
#EXT_TEST TIMEOUT 1000

./thread2thread.bash 3 3
