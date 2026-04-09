#!/bin/bash
#EXT_TEST TEST_FILE_DESC "Provide information on local tests"

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

../../bin/sst-ext-tests -d . | tee TEST.INFO
echo PASS
