#-- use the built-in script to run
export TERM=linux
export CC=clang
export CXX=clang++
export SST_INSTALL=/jenkins/sst-clang17-openmpi4.1.6-$BRANCH
export PATH=$PATH:/pkgs/Linux/Rocky93/openmpi-4.1.6/clang17/bin
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
    export ASAN_OPTIONS=detect_leaks=0
fi
./configure --prefix=$SST_INSTALL $DBGFLAGS
if [ "$HEADERCHECK" = true ] ; then
	./scripts/test-includes.pl
fi
make -j
make install
export PATH=$PATH:$SST_INSTALL/bin
which sst-test-core
#if [ "$SANITIZER" = true ]; then
#	echo "WARNING: sst-test-core tests with sanitizers enabled will always fail; Disabling sst-test-core"
#else
	sst-test-core
#fi
if [ "$EXTTEST" = true ] ; then
	rm -Rf ./sst-ext-tests
	git clone https://github.com/tactcomplabs/sst-ext-tests.git
	cd sst-ext-tests
    git checkout $EXTTESTBRANCH
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
