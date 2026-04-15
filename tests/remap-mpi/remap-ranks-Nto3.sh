#!/bin/bash
#EXT_TEST TEST_FILE_MINVER NEW
#EXT_TEST TEST_FILE_DESC "1:2,4:8 ranks checkpointed repartitioned to 3 ranks on restart"
#EXT_TEST TIMEOUT 120

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

./rt2rt.bash 1 1 3 1|| exit 1
./rt2rt.bash 2 1 3 1|| exit 2

./rt2rt.bash 4 1 3 1|| exit 4
./rt2rt.bash 5 1 3 1|| exit 5
./rt2rt.bash 6 1 3 1|| exit 6
./rt2rt.bash 7 1 3 1|| exit 7
./rt2rt.bash 8 1 3 1|| exit 8

echo "remap-ranks-Nto3.sh passed"
wait


