#!/bin/bash
@import Hermes
@import Foundation
@import File/check

if [[ $(File.exists "$(pwd)/$1") ]]; then

    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs w "$(pwd)/$1"
    if [[ $? == 0 ]]; then
        rm -rf "$(pwd)/$1"
    fi
else
    println "${RED}ERROR: $@ does not exist."
fi

