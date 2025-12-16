#!/bin/bash -x

echo "BUILDNAME=$BUILDNAME"
echo "WORKSPACE=$WORKSPACE"
cd $WORKSPACE || exit 2

echo "---> $0 Started in $PWD"

#-- unique to target
export SST_INSTALL=/Users/builduser/jenkins/install/sst-$BRANCH-macos26.1-clang20.1
export PATH=/opt/homebrew/bin:/opt/homebrew/opt/libtool/libexec/gnubin:$PATH

#-- common
export TERM=linux
export CC=/opt/homebrew/Cellar/llvm@20/20.1.8/bin/clang
export CXX=/opt/homebrew/Cellar/llvm@20/20.1.8/bin/clang++

echo "REPO=$REPO"
echo "BRANCH=$BRANCH"
echo "EXTTESTBRANCH=$EXTTESTBRANCH"
echo "EXTTESTARGS=$EXTTESTARGS"
echo "HEADERCHECK=$HEADERCHECK"
echo "EXTTEST=$EXTTEST"
echo "DEBUG=$DEBUG"
echo "CLANGFORMAT=$CLANGFORMAT"
echo "SANITIZER=$SANITIZER"
echo "VALGRIND=$VALGRIND"
echo $SST_INSTALL
echo $PATH

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
    # detect_leaks is not supported on Mac
    # export ASAN_OPTIONS=detect_leaks=0
fi
####
# Remove `--disable-mpi` on Linux systems!!!
####
./configure --prefix=$SST_INSTALL $DBGFLAGS --disable-mpi
if [ "$HEADERCHECK" = true ] ; then
	./scripts/test-includes.pl
fi
make -j4
make install
export PATH=$PATH:$SST_INSTALL/bin
which sst-test-core
sst-test-core

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
	make -j4
	if [ "$VALGRIND" = false ]; then
	    make test || ctest --rerun-failed --output-on-failure
	else
    	    ../scripts/valgrind_ctest
	fi
fi

echo "---> $0 Finished"
