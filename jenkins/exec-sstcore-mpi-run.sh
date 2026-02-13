#!/bin/bash
#
# ~/jenkins/exec-sstcore-mpi-run.sh
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# This file is a part of the SST-EXT-TESTS package.  For license
# information, see the LICENSE file in the top level directory of
# this distribution.
#
module load sst/dev cmake/3.22.1-gcc-13.2.0-qyvc7df
export TERM=linux
export CC=mpicc
export CXX=mpicxx
export SST_COMPONENT_BASE=`pwd`
export PATH=/usr/share/spack/root/opt/spack/linux-ubuntu22.04-skylake_avx512/gcc-13.2.0/openmpi-4.1.6-faz24xfepsjm2mhvv7k3m7hnaud7woul/bin:/usr/share/spack/root/opt/spack/linux-ubuntu22.04-skylake_avx512/gcc-13.2.0/libtool-2.4.7-dol5croqk62h6l5dmi6jko6tukb3q2ek/bin:/usr/share/spack/root/opt/spack/linux-ubuntu22.04-x86_64/gcc-11.4.0/gcc-13.2.0-ta2mwsr3hq46pazzf3czviyke3zw2xfl/bin:/usr/bin:/bin:/usr/sbin:/sbin:$INSTALL_PREFIX/bin
echo "SST INSTALLED TO `which sst`"
make test
