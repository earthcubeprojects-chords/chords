#!/bin/bash

# Kapacitor conditional startup
#
# Set KAPACITOR_ENABLED to true or TRUE to neable statup of kapacitor.
#

if [ -z "$KAPACITOR_ENABLED" ]; then
  export KAPACITOR_ENABLED="false"
fi

if [ $KAPACITOR_ENABLED == "TRUE" ]; then
  export KAPACITOR_ENABLED="true"
fi

# If enabled, start capacitor
if [ $KAPACITOR_ENABLED == "true" ]; then
  echo "*** Kapacitor enabled; starting"
  kapacitord
else
  echo "Kapaciptor was not enabled (via KAPACITOR_ENABLED); not starting"
fi
