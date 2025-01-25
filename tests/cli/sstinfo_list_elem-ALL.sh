#!/bin/bash

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
