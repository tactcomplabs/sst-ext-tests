#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1:4,6:8 threads checkpointed repartitioned to 5 threads on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 5|| exit 1
./thread2thread.bash 2 5|| exit 2
./thread2thread.bash 3 5|| exit 3
./thread2thread.bash 4 5|| exit 4

./thread2thread.bash 6 5|| exit 6
./thread2thread.bash 7 5|| exit 7
./thread2thread.bash 8 5|| exit 8

echo "remap-threads-Nto5.sh passed"
wait


