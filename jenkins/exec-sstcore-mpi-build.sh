#!/bin/bash
#
# ~/jenkins/exec-sstcore-mpi-build.sh
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# This file is a part of the SST-EXT-TESTS package.  For license
# information, see the LICENSE file in the top level directory of
# this distribution.
#
module load sst/dev
export TERM=linux
export CC=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin/gcc
export CXX=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin/g++
export CXXFLAGS=$TMPCXXFLAGS
echo "INSTALL_PREFIX is $INSTALL_PREFIX"
./autogen.sh
CC=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin/gcc CXX=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin/g++  ./configure --prefix=$INSTALL_PREFIX $DBGFLAGS
$HCHECK
make -j
make install
export PATH=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-skylake_avx512/gcc-13.2.0/openmpi-4.1.6-faz24xfepsjm2mhvv7k3m7hnaud7woul/bin:/usr/share/spack/root/opt/spack/linux-ubuntu22.04-skylake_avx512/gcc-13.2.0/libtool-2.4.7-dol5croqk62h6l5dmi6jko6tukb3q2ek/bin:/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin:/usr/bin:/bin:/usr/sbin:/sbin:$INSTALL_PREFIX/bin
$RUNCORETEST
git clone https://github.com/tactcomplabs/sst-ext-tests.git
cd sst-ext-tests
git checkout $EXTTESTBRANCH
export CC=mpicc
export CXX=mpicxx
mkdir build
cd build
#TODO cmake $EXTTESTASAN $EXTTESTARGS
# Need to check Jenkins configuration
cmake -DENABLE_MPI_TESTS=ON ../
export SST_COMPONENT_BASE=`pwd`
make
