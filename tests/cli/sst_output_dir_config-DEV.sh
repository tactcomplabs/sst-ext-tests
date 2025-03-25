#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests relocation of config files"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

check_odir() {
    odir=$1
    rm -Rf $odir
    sst --output-directory=$odir --output-config=sst_output_dir.config cli-sdl.py
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "ERROR : $retVal"
        exit $retVal
    fi
    if [ ! -d "$odir" ]; then
        echo "ERROR : Output directory ${odir} does not exist!"
        exit 1
    fi
    if [ ! -e "$odir/sst_output_dir.config" ]; then
        echo "ERROR missing checkpoint file $odir/sst_output_dir.config"
        exit 2
    fi
    rm -Rf $odir
    echo "${odir} OK"
}

tname=sst_output_dir_config

# Check 1: 1 level subdirectory
check_odir $tname.$$

# Check 2: 1 level subdirectory with ./
check_odir ./$tname.$$

# Check 3: Absolute path
check_odir "$(realpath .)/$tname.$$"

# Check 4: 2 level subdirectory
check_odir "$tname.$$/level2"

# ensure asynchronous rm -rF completed
wait

# All good
echo "PASS"
exit 0
