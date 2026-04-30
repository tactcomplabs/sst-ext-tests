#!/bin/bash
#EXT_TEST TEST_FILE_MINVER DEV
#EXT_TEST TEST_FILE_DESC "2 ranks, 4 threads/rank checkpointed. Restart repartioning with even combos"
#EXT_TEST TIMEOUT 300

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

# first pair is ranks and threads for checkpointed simulation.
# remaining pairs are for repartioned restart simulations

#            cpt   -- 1r rst  --   - 2r -   - 4r -    -8r-
./rt2rt.bash 2 4   1 8  1 4  1 2   2 2 2 1  4 2 4 1   8 1   || exit 1

echo "remap-combo-2r4t.sh passed"
wait
