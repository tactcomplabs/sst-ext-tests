#!/bin/bash -x

echo "BUILDNAME=$BUILDNAME"
echo "WORKSPACE=$WORKSPACE"
cd $WORKSPACE || exit 2

echo "---> $0 Started in $PWD"

#-- unique to target
export SST_INSTAL=/jenkins/sstcore-sles15-gcc15-openmpi4.1.7
export PATH=/usr/lib64/mpi/gcc/openmpi4/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/mpi/gcc/openmpi4/lib64
export OMPI_CC=gcc-15
export OMPI_CXX=g++-15

#-- common
export TERM=linux
export CC=gcc-15
export CXX=g++-15

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
	./scripts/clang-format-test.sh --format-exe /pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang-format
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
./configure --prefix=$SST_INSTALL $DBGFLAGS
if [ "$HEADERCHECK" = true ] ; then
	./scripts/test-includes.pl
fi
make -j
make install
export PATH=$PATH:$SST_INSTALL/bin
which sst-test-core
sst-test-core

if [ "$EXTTEST" = true ] ; then
	pwd
	cd sst-ext-tests
	mkdir build
	cd build
	if [ "$VALGRIND" = false ]; then
	    cmake -DENABLE_ALL_TESTS=ON $EXTTESTASAN $EXTTESTARGS ../
	else
    	    cmake -DENABLE_ALL_TESTS=ON -DENABLE_VALGRIND=ON $EXTTESTARGS ../
	fi
	export SST_COMPONENT_BASE=`pwd`
	make -j
	if [ "$VALGRIND" = false ]; then
	    make test || ctest --rerun-failed --output-on-failure
	else
    	    ../scripts/valgrind_ctest
	fi
fi

echo "---> $0 Finished"
