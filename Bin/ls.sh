#!/bin/bash
@import Hermes
@import Foundation
@import File/check

if [[ $(File.isDirectory "$(pwd)/$1") ]]; then

    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs r "$(pwd)/$1"
    if [[ $? == 0 ]]; then
        ls -1 "$(pwd)/$1"
    fi
else
    println "${RED}ERROR: $@ is not a directory"
fi

