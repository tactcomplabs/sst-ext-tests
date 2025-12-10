#!/bin/bash -x

# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details

# Usage:
# 1. Set platform specific environment variables. e.g.
#    export SST_INSTALL=/Users/builduser/jenkins/install/sst-$BRANCH-macos26.1-clang17.0-EXP
#    export PATH=/opt/homebrew/bin:/opt/homebrew/opt/libtool/libexec/gnubin:$PATH
# 2. Run it
#    run.sh

echo "---> $0 Started in $PWD"
echo "BUILDNAME=$BUILDNAME"
echo "WORKSPACE=$WORKSPACE"
cd $WORKSPACE || exit 2

#-- common
export TERM=linux
export CC=clang
export CXX=clang++

#-- environment feedback
echo "REPO=$REPO"
echo "BRANCH=$BRANCH"
echo "EXTTESTBRANCH=$EXTTESTBRANCH"
echo "EXTTESTARGS=$EXTTESTARGS"
echo "HEADERCHECK=$HEADERCHECK"
echo "EXTTEST=$EXTTEST"
echo "DEBUG=$DEBUG"
echo "CLANGFORMAT=$CLANGFORMAT"
echo "SST_TEST_CORE=$SST_TEST_CORE"
if [ $SANITIZER = true ] && [ $VALGRIND = true ]; then
	echo "SANITIZER and VALGRIND are mutually exclusive. Using SANITIZER only"
	VALGRIND=false
fi
echo "SANITIZER=$SANITIZER"
echo "VALGRIND=$VALGRIND"
echo $SST_INSTALL
echo $PATH

#-- SST
rm -Rf $SST_INSTALL/*
if [ "$CLANGFORMAT" = true ]; then
	./scripts/clang-format-test.sh --format-exe /opt/homebrew/opt/llvm@20/bin/clang-format
fi
./autogen.sh
if [ "$DEBUG" = true ]; then
    export DBGFLAGS="--enable-debug"
    export CXXFLAGS="-O0 -g"
else
	export DBGFLAGS=""
fi
if [ "$SANITIZER" = true ]; then
    export CXXFLAGS="${CXX_FLAGS} -g -fsanitize=address -fno-omit-frame-pointer"
    export EXTTESTASAN="-DSST_ASAN=ON"
	if [[ "$(uname)" != "Darwin" ]]; then
		# detect_leaks is not supported on Mac
		export ASAN_OPTIONS=detect_leaks=0
	fi
fi
./configure --prefix=$SST_INSTALL $DBGFLAGS --disable-mpi
if [ "$HEADERCHECK" = true ] ; then
	./scripts/test-includes.pl
fi
make -j4
make install
export PATH=$PATH:$SST_INSTALL/bin

#-- Run SST tests
if [ "$SST_TEST_CORE" = true ]; then
	which sst-test-core
	sst-test-core
fi

#-- Run EXT tests
if [ "$EXTTEST" = true ] ; then
	cd sst-text-tests
	mkdir build
	cd build
	if [ "$VALGRIND" = false ]; then
	    cmake -DENABLE_ALL_TESTS=ON $EXTTESTASAN $EXTTESTARGS ../
	else
    	cmake -DENABLE_ALL_TESTS=ON -DENABLE_VALGRIND=ON $EXTTESTARGS ../
	fi
	export SST_COMPONENT_BASE=`pwd`
	make
	if [ "$VALGRIND" = false ]; then
	    make test || ctest --rerun-failed --output-on-failure
	else
    	../scripts/valgrind_ctest
	fi
fi

echo "---> $0 Finished"
