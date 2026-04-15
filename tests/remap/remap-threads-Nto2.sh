#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1,3:8 threads checkpointed repartitioned to 2 threads on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./thread2thread.bash 1 2|| exit 1

./thread2thread.bash 3 2|| exit 3
./thread2thread.bash 4 2|| exit 4
./thread2thread.bash 5 2|| exit 5
./thread2thread.bash 6 2|| exit 6
./thread2thread.bash 7 2|| exit 7
./thread2thread.bash 8 2|| exit 8

echo "remap-threads-Nto2.sh passed"
wait


