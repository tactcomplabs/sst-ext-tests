# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
# See LICENSE in the top level directory for licensing details

# Usage: Use this script in the target->Configure->BuildSteps command

#-- use the built-in script to run

#-- Customize these environment variables for each target
export SST_INSTALL=/Users/builduser/jenkins/install/sst-$BRANCH-macos26.1-clang17.0-EXP
export PATH=/opt/homebrew/bin:/opt/homebrew/opt/libtool/libexec/gnubin:$PATH
export CC=clang
export CXX=clang++

###
### DO NOT EDIT BELOW THIS LINE
###

#--  sst-ext-tests contains script to execute tests for this target
#--  Always clone sst-ext-tests but conditionally run

rm -Rf ./sst-ext-tests
git clone https://github.com/tactcomplabs/sst-ext-tests.git
cd sst-ext-tests || exit 1
git checkout $EXTTESTBRANCH
cd ..

# Run Target Specific Override Script if it exists
runscript="sst-ext-tests/jenkins/${JOB_BASE_NAME}.sh"
if [[ -x ${runscript} ]]; then
  ${runscript}
  echo "Completed ${JOB_BASE_NAME} using ${runscript}"
  exit 0
fi

# Run common run script if it exists
runscript="sst-ext-tests/jenkins/run.sh"
if [[ ! -x ${runscript} ]]; then
  echo "Warning: ${runscript} not found. Skipping this run"
  exit 0
fi

${runscript}
echo "Completed ${JOB_BASE_NAME} using ${runscript}"
