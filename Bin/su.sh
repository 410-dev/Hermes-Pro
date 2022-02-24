#!/bin/bash

@import Hermes

# Elevate privilage
Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" exec ${1}
exitCode=$?

if [[ ${exitCode} == 0 ]]; then
    shellCommand "privilage 0"
fi