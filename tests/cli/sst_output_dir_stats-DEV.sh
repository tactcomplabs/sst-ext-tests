#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests statistics output file creation using --output-directory"
#EXT_TEST DEP "coreTestElement.coreTestComponent"

# Note: this is the same command line used in sst_output_dir-DEV.sh since statistics
# are enabled in cli-sdl.py. The only difference is that it checks the existence of 
# the statistics file in the expected output directory. If the file name changes
# in the sdl this test will start failing. If this is the case, let's add command 
# line options for the sdl to provide full control over these for testing.
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
    if [ ! -e "$odir/stats.csv" ]; then
    	echo "ERROR : Output directory ${odir}/stats.csv does not exist!"
	    exit 2
    fi
    rm -Rf $odir
    echo "${odir} OK"
}

tname=sst_output_dir_stats

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
