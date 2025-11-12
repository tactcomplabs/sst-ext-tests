#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR=$(realpath "${SCRIPT_DIR}"/../bin)
TESTS_DIR=$(realpath "${SCRIPT_DIR}"/../tests)
BUILD_DIR=$(realpath "${SCRIPT_DIR}"/../build)
mkdir -p ${BUILD_DIR} || exit 1

host=$(hostname)
if [[ "$host" == "gizmo.dev.tactcomplabs.com" ]]; then
    echo "Running audit on $host"
else
    echo "Must by on gizmo to run this audit"
fi

id=$(date "+%y%m%d")
mkdir -p $id || exit 2
cd $id || exit 2
rm -f *

AUDIT_DIR=$(realpath .)
echo -n "Audit directory is $AUDIT_DIR"

pushd ${AUDIT_DIR} || exit 3
date > info.audit
hostname >> info.audit
uname -a >> info.audit
git status >> info.audit
git log -1 --oneline >> info.audit

# just need a later version of sst to make cmake happy at this point
module load sst/15.1.0 || exit 89
${BIN_DIR}/sst-ext-tests -d ${TESTS_DIR} | tee tests.info || exit 90
${SCRIPT_DIR}/audit.sh | tee testlist.audit || exit 91
popd

# Enter build directory
pushd $BUILD_DIR || exit 4

# module av sst
versions=("sst/13.0.0" "sst/13.1.0" "sst/14.0.0" "sst/14.1.0" "sst/15.0.0" "sst/15.1.0")
for v in "${versions[@]}"; do
    
    echo
    echo "### Loading $v ###"
    echo

    module unload sst
    module load $v || exit 92
    hash -r
    sst --version || exit 93

    nversion=$(echo $v | awk -F/ '{print $2}')
    echo $nversion

    make clean uninstall >& /dev/null
    rm -rf * .cmake

    cmake -DENABLE_ALL_TESTS=ON .. || exit 100

    make -j -s 

    ctest -j 20 | tee ${AUDIT_DIR}/$nversion.ctest
    wait
done
popd
echo "audit-gizmo.sh finished normally. See $AUDIT_DIR"
wait
