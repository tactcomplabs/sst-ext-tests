#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 15.1
#EXT_TEST TEST_FILE_DESC "8 thread checkpointed repartitioned to 1 thread restart"
#EXT_TEST TIMEOUT 120

./thread2thread.bash 8 1
