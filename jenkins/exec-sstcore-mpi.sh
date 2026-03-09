#!/bin/bash
#
# ~/jenkins/exec-sstcore-mpi.sh
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# This file is a part of the SST-EXT-TESTS package.  For license
# information, see the LICENSE file in the top level directory of
# this distribution.
#
# Usage: exec-sstcore-mpi.sh $BRANCH $DEBUG $SANITIZER $HEADERCHECK $EXTTEST $EXTTESTBRANCH $VALGRIND
#
USER=$(id -un)

#-- setup the environment
/jenkins/scripts/setup-env.sh

#-- gather the arguments
TMPBRANCH="$1"
export BRANCH="${TMPBRANCH##*([^a-zA-Z0-9])}"
export DEBUG=$2
export SANITIZER=$3
export HEADERCHECK=$4
export EXTTEST=$5
export EXTTESTBRANCH=$6
export VALGRIND=$7
SCRIPT="/jenkins/scripts/exec-sstcore-mpi-build.sh"

#-- build the compilation scripts
export INSTALL_PREFIX="`pwd`/install"
echo "INSTALLING TO: $INSTALL_PREFIX"
mkdir -p $INSTALL_PREFIX
if [ "$DEBUG" = true ]; then
	export DBGFLAGS="--enable-debug"
	export TMPCXXFLAGS="-O0 -g"
else
	export DBGFLAGS=""
fi

if [ "$SANITIZER" = true ]; then
	export TMPCXXFLAGS="-g3 -O0 -fsanitize=address"
	export RUNCORETEST="echo \"Bypassing sst-test-core...\""
else
	export RUNCORETEST="sst-test-core"
fi

if [ "$HEADERCHECK" = true ]; then
	export HCHECK="./scripts/test-includes.pl"
else
	export HCHECK="echo \"Bypassing header check....\""
fi


#-- execute the build job
SLURM_ID=$(sbatch -N1 -p normal --export=ALL "$SCRIPT" | awk '{print $4}')

#-- wait for completion
COMPLETE=$(squeue -u "$USER" | grep "${SLURM_ID}")
while [[ -n $COMPLETE ]]; do
  sleep 1
  COMPLETE=$(squeue -u "$USER" | grep "${SLURM_ID}")
done

#-- echo the result to the log
cat "slurm-${SLURM_ID}.out"

#-- job has completed, test for status
FAILED=$(grep "FAILED" < "slurm-${SLURM_ID}.out")

if [[ -z "$FAILED" ]];
then
  echo "TEST PASSED FOR JOB_ID = ${JOB_ID}; SLURM_JOB=${SLURM_ID}"
  echo "$STATE"
else
  echo "TEST FAILED FOR JOB_ID = ${JOB_ID}; SLURM_JOB=${SLURM_ID}"
  echo "$STATE"
  exit 1
fi

MPISCRIPT="/jenkins/scripts/exec-sstcore-mpi-run.sh"
cd sst-ext-tests/build

#-- execute the mpi job
if [ "$EXTTEST" = true ]; then
	SLURM_ID=$(sbatch -N2 -p normal --export=ALL "$MPISCRIPT" | awk '{print $4}')

	#-- wait for completion
	COMPLETE=$(squeue -u "$USER" | grep "${SLURM_ID}")
	while [[ -n $COMPLETE ]]; do
  		sleep 1
  		COMPLETE=$(squeue -u "$USER" | grep "${SLURM_ID}")
	done

	#-- echo the result to the log
	cat "slurm-${SLURM_ID}.out"

	#-- job has completed, test for status
	FAILED=$(grep "FAILED" < "slurm-${SLURM_ID}.out")

	if [[ -z "$FAILED" ]];
	then
  		echo "TEST PASSED FOR JOB_ID = ${JOB_ID}; SLURM_JOB=${SLURM_ID}"
  		echo "$STATE"
  		exit 0
	else
  		echo "TEST FAILED FOR JOB_ID = ${JOB_ID}; SLURM_JOB=${SLURM_ID}"
  		echo "$STATE"
  		exit 1
	fi
fi

exit 0

#-- EOF
