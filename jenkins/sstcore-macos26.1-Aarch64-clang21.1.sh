#!/bin/bash -x

echo "BUILDNAME=$BUILDNAME"
echo "WORKSPACE=$WORKSPACE"
cd $WORKSPACE || exit 2

echo "---> $0 Started in $PWD"

#-- unique to target
export SST_INSTALL=/Users/builduser/jenkins/install/sst-$BRANCH-macos26.1-clang21.1-kg
export PATH=/opt/homebrew/bin:/opt/homebrew/opt/libtool/libexec/gnubin:$PATH

#-- common
export TERM=linux
export CC=/opt/homebrew/Cellar/llvm/21.1.6/bin/clang
export CXX=/opt/homebrew/Cellar/llvm/21.1.6/bin/clang++

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
  ./scripts/clang-format-test.sh --format-exe /opt/homebrew/opt/llvm@20/bin/clang-format || exit 10
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
    # detect_leaks is not supported on Mac
    # export ASAN_OPTIONS=detect_leaks=0
fi
####
# Remove `--disable-mpi` on Linux systems!!!
####
./configure --prefix=$SST_INSTALL $DBGFLAGS --disable-mpi || exit 11
if [ "$HEADERCHECK" = true ] ; then
  ./scripts/test-includes.pl || exit 20
fi
make -j10 || exit 30
make install || exit 31
export PATH=$PATH:$SST_INSTALL/bin

#-- Run SST tests
if [ "$SST_TEST_CORE" = true ]; then
        which sst-test-core || exit 40
		mkdir -p kgtest
		rm -rf kgtest/*
		sst-test-core -f -w "*_R*" -o kgtest || exit 41
		sst-test-core -f -w "*_R*" -o kgtest || exit 42
		sst-test-core -f -w "*_R*" -o kgtest || exit 43
		sst-test-core -f -w "*_R*" -o kgtest || exit 44
		sst-test-core -f -w "*_R*" -o kgtest || exit 45
		sst-test-core -f -w "*_R*" -o kgtest || exit 46
		sst-test-core -f -w "*_R*" -o kgtest || exit 47
		sst-test-core -f -w "*_R*" -o kgtest || exit 48
		sst-test-core -f -w "*_R*" -o kgtest || exit 49
fi

if [ "$EXTTEST" = true ] ; then
	pwd
	cd sst-ext-tests || exit 50
	mkdir build || exit 51
	cd build || exit 52
	if [ "$VALGRIND" = false ]; then
	    cmake -DENABLE_ALL_TESTS=ON $EXTTESTASAN $EXTTESTARGS ../ || exit 53
	else
    	    cmake -DENABLE_ALL_TESTS=ON -DENABLE_VALGRIND=ON $EXTTESTARGS ../ || exit 54
	fi
	export SST_COMPONENT_BASE=`pwd`
	make -j10 || exit 55
	if [ "$VALGRIND" = false ]; then
	    make test || ctest --rerun-failed --output-on-failure || exit 56
	else
    	    ../scripts/valgrind_ctest || exit 60
	fi
fi

echo "---> $0 Finished"
