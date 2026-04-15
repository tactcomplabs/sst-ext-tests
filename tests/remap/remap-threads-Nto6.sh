#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1:5,7:8 threads checkpointed repartitioned to 6 threads on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 6|| exit 1
./thread2thread.bash 2 6|| exit 2
./thread2thread.bash 3 6|| exit 3
./thread2thread.bash 4 6|| exit 4
./thread2thread.bash 5 6|| exit 5

./thread2thread.bash 7 6|| exit 7
./thread2thread.bash 8 6|| exit 8

echo "remap-threads-Nto6.sh passed"
wait


