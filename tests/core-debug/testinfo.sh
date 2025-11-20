#!/bin/bash
#EXT_TEST TEST_FILE_DESC "Provide information on local tests"
../../bin/sst-ext-tests -d . || exit 11 | tee TEST.INFO
echo PASS
