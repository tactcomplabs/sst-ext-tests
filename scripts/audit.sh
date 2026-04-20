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
pwd

# CMakeLists.txt:129
versions=("13.0" "13.1" "14.0" "14.1" "15.0" "15.1" "15.2" "DEV")
for v in "${versions[@]}"; do
    echo
    echo "### Checking test selection for sst version $v ###"
    echo
    # Clear cmake cache and remake
    rm -rf * .cmake
    cmake .. -DSST_VERSION=$v -DENABLE_ALL_TESTS=ON > /dev/null || exit 2
    # List the tests
    ctest --show-only
done

# EOF
