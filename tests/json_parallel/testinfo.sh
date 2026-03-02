#!/bin/bash
#EXT_TEST TEST_FILE_DESC "Provide information on local tests"
../../bin/sst-ext-tests -d . | tee TEST.INFO
echo PASS | tee TEST.INFO
