#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1:6,8 threads checkpointed repartitioned to 7 threads on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 7|| exit 2
./thread2thread.bash 2 7|| exit 2
./thread2thread.bash 3 7|| exit 3
./thread2thread.bash 4 7|| exit 4
./thread2thread.bash 5 7|| exit 5
./thread2thread.bash 6 7|| exit 6

./thread2thread.bash 8 7|| exit 8

echo "remap-threads-Nto7.sh passed"
wait


