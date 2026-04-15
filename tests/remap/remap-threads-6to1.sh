#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "6 thread checkpointed to 1 thread restart"
#EXT_TEST TIMEOUT 600

./thread2thread.bash 6 1
