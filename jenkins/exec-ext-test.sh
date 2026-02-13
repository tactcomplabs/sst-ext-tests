#!/bin/bash
#
# ~/jenkins/exec-test.sh
#
# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# This file is a part of the SST-EXT-TESTS package.  For license
# information, see the LICENSE file in the top level directory of
# this distribution.
#
USER=$(id -un)

#-- setup the environment
/jenkins/scripts/setup-env.sh

#-- execute the job
SCRIPT=$1
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
  exit 0
else
  echo "TEST FAILED FOR JOB_ID = ${JOB_ID}; SLURM_JOB=${SLURM_ID}"
  echo "$STATE"
  exit 1
fi

#-- EOF
