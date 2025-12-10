This area contains scripts used by Jenkins sst-core development pipeline.

  
- `serverside.sh`:  Copy this script into the build steps 'command' text window. Modify SST_INSTALL and PATH for the target system. This will invoke `run.sh` unless an override script exists, `sst-ext-tests/jenkins/${JOB_BASE_NAME}.sh`
- `run.sh`: This is invoked by `servserside.sh` 
- examples/sstcore-macos26.1-Aarch64-clang17.0-EXP.sh: Example override script. Copy to parent directory for `sstcore-macos26.1-Aarch64-clang17.0` to use this script instead of `run.sh`
