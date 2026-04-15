#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1 to 7 threads checkpointed repartitioned to 8 threads on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 8 || exit 1
./thread2thread.bash 2 8 || exit 2
./thread2thread.bash 3 8 || exit 3
./thread2thread.bash 4 8 || exit 4
./thread2thread.bash 5 8 || exit 5
./thread2thread.bash 6 8 || exit 6
./thread2thread.bash 7 8 || exit 7

echo "remap-threads-Nto8.sh passed"
wait


