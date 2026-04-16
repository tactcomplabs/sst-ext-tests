#!/bin/bash

# Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details
#
# thread2thread.sh

# ensure non-zero exit code in pipe propagates and no unbound variables.
set -uo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: thread2thread.bash threads_checkpointed threads_restarted"
  exit 1
fi

threads_cpt=$1
threads_rst=$2

# --add-lib-path required for Jenkins runs (does not run 'make install')
# Set default ensure failure if not set and component not installed
SST_COMPONENT_BASE="${SST_COMPONENT_BASE:=.}"

# Settings
CLEANUP=1
SCRIPT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=$(basename "$0")
TNAME="${SCRIPT_NAME%.*}_${threads_cpt}_${threads_rst}_$$"
echo "TESTNAME=$TNAME"
LOGFILE=${TNAME}.log
PFX="cpt_${TNAME}"
CONFIG="loop101.py"


# Clean up old checkpoint directory
rm -rf ${PFX}*

# Launch the program to start interactive mode at time 0
LAUNCH="sst --num-threads=${threads_cpt} --checkpoint-sim-period=98047ns --checkpoint-prefix=$PFX --add-lib-path=$SST_COMPONENT_BASE/core-debug $CONFIG -- --verbose=0"
echo $LAUNCH
$LAUNCH | tee $LOGFILE
retVal=$?
echo $TNAME Checkpointing simulation complete

# Check result
if [ $retVal -ne 0 ]; then
  echo "ERROR $TNAME returned $retVal"
  exit $retVal
fi

echo "Checkpoints: "
ls ${PFX}

n=$(ls ${PFX} | wc -l)
if [[ $n -lt 10 ]]; then
  echo "ERROR: expected at least 10 checkpoints but found $n"
  exit 1
fi

PSTR="Simulation is complete, simulated time: 1.0017 ms"
egrep "$PSTR" $LOGFILE > /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
  exit $retVal
fi
echo "Found pass string \"$PSTR\""

# Rerun all the checkpoints
n=0
for cptfile in ${PFX}/${PFX}_*/${PFX}_*.sstcpt; do

  ((n++))
  LAUNCH="sst --num-threads=${threads_rst} --load-checkpoint ${cptfile}"
  echo $LAUNCH
  $LAUNCH | tee $LOGFILE
  retVal=$?
  echo $TNAME Restart of ${cptfile} complete

  if [ $retVal -ne 0 ]; then
    echo "ERROR $TNAME restart of ${cptfile} returned $retVal"
    exit $retVal
  fi

  egrep "$PSTR" $LOGFILE > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "ERROR could not find pass string in $LOGFILE \"$PSTR\""
    exit $retVal
  fi
  echo "Found pass string \"$PSTR\" for restart of ${cptfile}"

done

if [[ $n -lt 10 ]]; then
  echo "ERROR: expected at least 10 restart simulations but found $n"
  exit 1
fi

# Cleanup output file on pass
if [ $CLEANUP -eq 1 ]; then
  rm -f $LOGFILE
  rm -rf ${PFX}*
fi

wait
echo "PASS"
exit 0
