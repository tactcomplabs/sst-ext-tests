#!/bin/bash

# Audit tests included.
# Intended to be compared against results from the alternate test flow (alt.sh)

# Directory containing script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Presumed build directory
BUILD_DIR=$(realpath "${SCRIPT_DIR}"/../build)
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Could not locate build directory: ${BUILD_DIR}"
    exit 1
fi

cd ${BUILD_DIR}

# SST version at top of file
sst --version
pwd
# Clear cmake cache and remake
rm -rf * .cmake
cmake .. -DENABLE_ALL_TESTS=ON > /dev/null || exit 2
# List the tests
ctest --show-only

# EOF
