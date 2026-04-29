#!/bin/bash -x

echo "BUILDNAME=$BUILDNAME"
echo "WORKSPACE=$WORKSPACE"
cd $WORKSPACE || exit 2

echo "---> $0 Started in $PWD"

#-- unique to target
export SST_INSTALL=/jenkins/sstcore-sles15-clang20-mpich4.1.2
export PATH=/usr/lib64/mpi/gcc/mpich/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/mpi/gcc/mpich/lib64
export MPICH_CC=/pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang
export MPICH_CXX=/pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang++

#-- common
export TERM=linux
export CC=/pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang
export CXX=/pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang++

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

export PYFLAGS="--with-python=/usr/bin/python3.11-config"

rm -Rf $SST_INSTALL/*
if [ "$CLANGFORMAT" = true ]; then
  ./scripts/clang-format-test.sh --format-exe /pkgs/Linux/Rocky93/LLVM/LLVM-20.1.0-Linux-X64/bin/clang-format || exit 10
fi
./autogen.sh || exit 3
if [ "$DEBUG" = true ]; then
  export DBGFLAGS="--enable-debug"
  export CXXFLAGS="-O0 -g"
else
  export DBGFLAGS=""
fi
if [ "$SANITIZER" = true ]; then
    export CXXFLAGS="${CXX_FLAGS} -g -fsanitize=address -fno-omit-frame-pointer"
    export EXTTESTASAN="-DSST_ASAN=ON"
	# suppress detecting leaks until we get them cleaned up.
    # detect_leaks is not supported on Mac
    export ASAN_OPTIONS=detect_leaks=0
fi
./configure --prefix=$SST_INSTALL $DBGFLAGS $PYFLAGS || exit 11
if [ "$HEADERCHECK" = true ] ; then
  ./scripts/test-includes.pl || exit 20
fi
make -j || exit 30
make install || exit 31
export PATH=$PATH:$SST_INSTALL/bin

#-- Run SST tests
if [ "$SST_TEST_CORE" = true ]; then
        which sst-test-core || exit 40
        sst-test-core || exit 41
fi

if [ "$EXTTEST" = true ] ; then
	pwd
	cd sst-ext-tests || exit 50
	mkdir build || exit 51
	cd build || exit 52
	if [ "$VALGRIND" = false ]; then
	    cmake $EXTTESTASAN $EXTTESTARGS ../ || exit 53
	else
    	cmake -DENABLE_VALGRIND=ON $EXTTESTARGS ../ || exit 54
	fi
	export SST_COMPONENT_BASE=`pwd`
	make -j || exit 55
	if [ "$VALGRIND" = false ]; then
	    make test || ctest --rerun-failed --output-on-failure || exit 56
	else
    	    ../scripts/valgrind_ctest || exit 60
	fi
fi

echo "---> $0 Finished"
