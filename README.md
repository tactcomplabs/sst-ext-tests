# sst-ext-tests : SST External Test Suite

![sst-ext-tests](imgs/logo.png)

SST External Test Suite

## Introduction

## Requirements
- CMake 3.19+
- SST + SST-Elements in the current `PATH`

## Executing SST-EXT-TESTS

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
However, the file name convention for each subdirectory will drive whether tests 
are enabled or disabled.

Files are named in the following form:
```
testname-VERSION.ext
```

The `testname` is an arbitrary string that contain underscores, dashes and periods.
The filename extension `ext` is based upon the current subdirectory's harness.  
The `VERSION` string determines whether the test will be enabled for the specific 
version of SST.  The `VERSION` string can be written in one of the following forms:

- `ALL` : Instructs the harness to enable the test for all versions of SST.  EX: `test-ALL.sh`
- `DEV` : Instructs the harness to enable the test if no known version exists.  EG, the version of 
SST was installed from a development source tree, not a release tree. EX: `test-DEV.sh`
- `VERSION` : Instructs the harness to enable the test for the specific version of SST.  EX: `test-14.1.sh`
- `MINVERSION` : Instructs the harness to enable the test for the minimum version of SST.  EX: `test-MIN14.0.sh`

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

## Acknowledgements
* TBD
