#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "4 ranks, 2 threads/rank checkpointed. Restart repartioning with even combos"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# first pair is ranks and threads for checkpointed simulation.
# remaining pairs are for repartioned restart simulations

#            cpt   -- 1r rst  --     - 2r -      -8r-
./rt2rt.bash 4 2   1 8  1 4  1 2   2 4 2 2 2 1   8 1 || exit 1

echo "remap-combo-4r2t.sh passed"
wait
