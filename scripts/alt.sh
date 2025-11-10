#!/bin/bash

# Directory containing script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEST_DIR=$(realpath "${SCRIPT_DIR}"/../tests)

sst --version

mkfiles=$(find ${TEST_DIR} -name Makefile)
for m in ${mkfiles}; do
    dir=$(dirname "${m}")
    echo "####################"
    echo "make -C $dir clean"
    echo "make -C $dir -j"
    echo "####################"
    make -C $dir clean
    make -C $dir -j
done

# EOF
