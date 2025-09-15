#!/bin/bash
#
# Unregisters components from the SST infrastructure
#

#-- unregister it
sst-register -u captcrunch

#-- forcible remove it from the local script
CONFIG=~/.sst/sstsimulator.conf
if test -f "$CONFIG"; then
  echo "Removing configuration from local config=$CONFIG"
  sed -i.bak '/captcrunch/d' $CONFIG
fi

