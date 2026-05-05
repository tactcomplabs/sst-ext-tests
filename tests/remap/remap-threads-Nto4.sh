#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "1:3,5:8 threads checkpointed repartitioned to 4 threads on restart"
#EXT_TEST TIMEOUT 1000

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 4|| exit 1
./thread2thread.bash 2 4|| exit 2
./thread2thread.bash 3 4|| exit 3

./thread2thread.bash 5 4|| exit 5
./thread2thread.bash 6 4|| exit 6
./thread2thread.bash 7 4|| exit 7
./thread2thread.bash 8 4|| exit 8

echo "remap-threads-Nto4.sh passed"
wait


