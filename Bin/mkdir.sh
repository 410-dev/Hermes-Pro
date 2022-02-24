#!/bin/bash
@import Hermes
@import Foundation
@import File/check

if [[ ! $(File.isFile "$(pwd)/$1") ]]; then

    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs w "$(pwd)/$1"
    if [[ $? == 0 ]]; then
        mkdir -p "$(pwd)/$1"
    fi
else
    println "${RED}ERROR: $@ is a file."
fi

