#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests basic directory creation using --output-directory"
#EXT_TEST DEP "coreTestElement.coreTestComponent"
#EXT_TEST TIMEOUT 240

check_odir() {
    odir=$1
    rm -Rf $odir
    sst --output-directory=$odir cli-sdl.py
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "ERROR : $retVal"
        exit $retVal
    fi
    if [ ! -d "$odir" ]; then
        echo "ERROR : Output directory ${odir} does not exist!"
        exit 1
    fi
    rm -Rf $odir
    echo "${odir} OK"
}

tname=sst_output_dir

# Check 1: 1 level subdirectory
check_odir $tname.$$

# Check 2: 1 level subdirectory with ./
check_odir ./$tname.$$

# Check 3: Absolute path
check_odir "$(readlink -f .)/$tname.$$"

# Check 4: 2 level subdirectory
check_odir "$tname.$$/level2"

# ensure asynchronous rm -rF completed
wait

# All good
echo "PASS"
exit 0
