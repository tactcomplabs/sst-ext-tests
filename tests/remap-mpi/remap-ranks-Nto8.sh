#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1 to 7 ranks checkpointed repartitioned to 8 ranks on restart"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./rt2rt.bash 1 1 8 1 || exit 1
./rt2rt.bash 2 1 8 1|| exit 2
./rt2rt.bash 3 1 8 1|| exit 3
./rt2rt.bash 4 1 8 1|| exit 4
./rt2rt.bash 5 1 8 1|| exit 5
./rt2rt.bash 6 1 8 1|| exit 6
./rt2rt.bash 7 1 8 1|| exit 7

echo "remap-ranks-Nto8.sh passed"
wait


