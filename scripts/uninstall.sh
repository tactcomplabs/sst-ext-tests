#!/bin/bash
#
# Unregisters components from the SST infrastructure
#

#--remove files from cmake install manifest                                           
xargs rm < install_manifest.txt

#-- unregister it
sst-register -u captcrunch
sst-register -u dbgsst15

#-- forcible remove it from the local script
CONFIG=~/.sst/sstsimulator.conf
if test -f "$CONFIG"; then
  echo "Removing configuration from local config=$CONFIG"
  sed -i.bak '/captcrunch/d' $CONFIG
  sed -i.bak '/dbgsst15/d' $CONFIG
fi

