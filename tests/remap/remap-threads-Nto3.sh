#!/bin/bash
#EXT_TEST TEST_FILE_MINVER 16.0
#EXT_TEST TEST_FILE_DESC "1:2,4:8 threads checkpointed repartitioned to 3 threads on restart"
#EXT_TEST TIMEOUT 1000

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 3|| exit 1
./thread2thread.bash 2 3|| exit 2

./thread2thread.bash 4 3|| exit 4
./thread2thread.bash 5 3|| exit 5
./thread2thread.bash 6 3|| exit 6
./thread2thread.bash 7 3|| exit 7
./thread2thread.bash 8 3|| exit 8

echo "remap-threads-Nto3.sh passed"
wait


