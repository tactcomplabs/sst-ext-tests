#!/bin/bash
#EXT_TEST TEST_FILE_PARAM ALL
#EXT_TEST TEST_FILE_DESC "Tests printing sst-info for all the appropriate ELEMENT LIBRARY values"

for a in `sst-info | grep "ELEMENT LIBRARY" | awk '{print $5}'`;do
  sst-info $a
done;

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "ERROR"
  exit $retVal
fi
echo "PASS"
exit $retVal
