# sst-ext-tests : SST External Test Suite

![sst-ext-tests](imgs/logo.png)

SST External Test Suite

## Introduction

## Requirements
- CMake 3.19+
- SST + SST-Elements in the current `PATH`

## Executing SST-EXT-TESTS

To build and run all tests use:

```
mkdir build && cd build
cmake -DENABLE_ALL_TESTS=ON ..
make install
make test
```

Flags for test selection include:
```
# Enables golden (production) test suite
ENABLE_ALL_TESTS [OFF]

# Enables NEW tests (non-production) and ALL production tests
# For these the test header is: #EXT_TEST TEST_FILE_MINVER NEW
ENABLE_NEW_TESTS [OFF]

#  Note: The NEW tests will be added only when SST_VERSION is DEV.
#  This can be achieved two ways:
#  1. sst executable points to a `devel` branch
#     `cmake .. -DENABLE_NEW_TESTS=ON`
#  2. Use the SST_VERSION override option
#     `cmake .. -DENABLE_NEW_TESTS=ON` -DSST_OVERRIDE=DEV

# Individual suites by ENABLE_ALL_TESTS=ON
ENABLE_CLI_TESTS [OFF]
ENABLE_CAPTCRUNCH_TESTS [OFF]
ENABLE_RTACTION_TESTS [OFF]

# Currently optional tests
ENABLE_MPI_TESTS [OFF]
ENABLE_CORE_CHKPT_TESTS [OFF]

# Enabling Valgrind testing (see additional details below)
ENABLE_VALGRIND [OFF]
```

## Valgrind Testing
*SST-EXT-TESTS* provides an automated mechanism for executing tests using the 
standard *Valgrind* memory checking tool.  Enabling valgrind testing requires 
several additional packages and/or testing steps.  We outline these as follows:

* *Valgrind* must be installed on the respective test system.  Use `dpkg install valgrind` 
on RedHat/RedHat-clone systems, `apt-get install valgrind` on Ubuntu systems and 
`brew install valgrind` on MacOS systems
* Executing the tests must be performed using the generated `valgrind_ctest` 
script in the `~/scripts` folder.  From the build directory, this will 
be analogous to:
```
../scripts/valgrind_ctest
```
* The valgrind script explicitly sets the valgrind error exit code to 99
(`valgrind --error-exitcode=99`).  This allows us to detect the difference 
between a failed test or valgrind finding an issue.  If a test passes and 
valgrind does not find an issue, the exit code will be 0.  If a test passes 
but valgrind finds an issue, the return code will be `99`.  If the test fails 
and valgrind finds an issue, the return code will be `99`.  If the test fails 
and sends a non-zero return code, but valgrind does not find any errors, the return 
code will be the non-zero code from the test.
* *Valgrind* has a large number of potential runtime options.  These options can 
be specified on the command line or via a standard `rc` file.  We highly 
recommend that users/developers utilize a standard `rc` file methodology 
in order to ensure that all testing is performed in a homogeneous manner.  
TCL currently utilizes the `rc` listed below for all *SST-EXT-TESTS* Valgrind 
efforts.  This file is placed in your home directory at `~/.valgrindrc`.

Sample `.valgrindrc` file:
```
--trace-children=yes
--track-origins=yes
--leak-check=no
--partial-loads-ok=no
--redzone-size=2048
--malloc-fill=88
--free-fill=cc
--freelist-vol=10000000000
--expensive-definedness-checks=yes
--log-file=valgrind-out.txt
```
* Finally, be aware that enabling the *Valgrind* testing will *significantly* 
increase the time required to run the tests.  The default timeout values for 
each test are increased by `10X`.

## Test Format

*SST-EXT-TESTS* are formatted such that tests can be executed across different 
platforms and different configurations of SST without modifying the test harness 
and/or the contents of the tests.  All tests follow a specific file name convention 
that directs the build system to enable or disable specific tests based upon the 
version of SST detected in the current path.  This detection mechanism is currently 
*only* based upon what is in the current `PATH` variable.  Future versions of the harness 
will provide the ability to specify an SST install location.

Each test subdirectory will contain a number of test drivers.  Each subdirectory 
will contain an additional *README.md* file that will describe the type of tests 
and the constituent file extensions that are supported for that directory tree.
However, metadata in each test file will drive whether tests are enabled or disabled.

All new tests must include metadata in the file header describing which versions of
SST are allowed for the test as well as a short test description

These are outlined as follows:
- `#EXT_TEST TEST_FILE_MINVER minver` : where `minver` is the minimum allowed version number (e.g. 14.0)
- `#EXT_TEST TEST_FILE_MAXVER maxver` : where `maxver` is the maximum allowed version number (e.g. 15.1)
- `#EXT_TEST TEST_FILE_DESC "DESC"` : where `DESC` is a description of the test

If either the minimum or maximum version number is omitted then that constraint is not used in test selection.
For example, to select all versions of SST starting at 13.1, set the minimum version to 13.1 and 
omit the maximum version. To select only version 13.1, select both min and max to 13.1.

Special cases
- `#EXT_TEST TEST_FILE_MINVER NEW: These tests will be included only when using -DENABLE_NEW_TESTS=ON`
- Unrecognized strings for TEST_FILE_MINVER results in automatic inclusions for all SST versions.

Optional metadata elements include:
- `#EXT_TEST DEP "COMP1 COMP2"`     : where within the quotes is a list of components
- `#EXT_TEST TIMEOUT XX`            : where XX is the number of seconds for the script to timeout (default is 60)
- `#EXT_TEST MPIARGS arg1 arg2`     : where arg1, arg2, etc are the arguments for the MPI execution command (mpirun, mpiexec)

## Test Interrogation
`sst-ext-tests` includes a Python tool that discovers appropriately 
configured tests in a recurisve manner.  The `sst-ext-tests` in the `bin` 
directory will recursively walk test directories, discover appropriate 
tests and print their details on the console or to a JSON file.  Examples 
of doing so include:

```
./bin/sst-ext-tests --help
./bin/sst-ext-tests -d ./tests/
./bin/sst-ext-tests -d ./tests -j output.json
./bin/sst-ext-tests -d ./tests -p ALL
```
## Test Selection

The default set of sets will be based on the version of SST found in the PATH
environment variable. To override this, use `cmake -DSST_VERSION=<version>`.
Example:

```
cmake .. -DSST_VERSION=14.1 -DENABLE_ALL_TESTS=ON
```

## Automation for Legacy SST Testing

For systems supporting environment `modules`, a reference script is provided
to test all supported versions of sst. Some customization will likely be
required.

Usage:

```
cd audit
../scripts/audit-gizmo.sh | tee log
```

Refer to the `audit` directory for example output.

## Contributing

We welcome outside contributions from corporate, academic and individual
developers. However, there are a number of fundamental ground rules that you
must adhere to in order to participate. These rules are outlined as follows:

* By contributing to this code, one must agree to the licensing described in
the top-level [LICENSE](LICENSE) file.
* All code must adhere to the existing C++ coding style. While we are somewhat
flexible in basic style, you will adhere to what is currently in place. This
includes camel case C++ methods and inline comments. Uncommented, complicated
algorithmic constructs will be rejected.
* We support compilaton and adherence to C++ standard methods. All new methods
and variables contained within public, private and protected class methods must
be commented using the existing Doxygen-style formatting. All new classes must
also include Doxygen blocks in the new header files. Any pull requests that
lack these features will be rejected.
* All changes to functionality and the API infrastructure must be accompanied
by complementary tests All external pull requests **must** target the `devel`
branch. No external pull requests will be accepted to the master branch.
* All external pull requests must contain sufficient documentation in the pull
request comments in order to be accepted.

## License

See the [LICENSE](./LICENSE) file

## Authors
* *John Leidel* - [Tactical Computing Labs](http://www.tactcomplabs.com)
* *Ken Griesser* - [Tactical Computing Labs](http://www.tactcomplabs.com)
* *Shannon Kuntz* - [Tactical Computing Labs](http://www.tactcomplabs.com)
* *Chris Taylor* - [Tactical Computing Labs](http://www.tactcomplabs.com)

## Acknowledgements
* TBD
