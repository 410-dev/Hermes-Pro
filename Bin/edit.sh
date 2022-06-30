#!/bin/bash
@import Hermes
@import Foundation
@import File/check

if [[ $(String.isNull $1) ]]; then
    println "${RED}ERROR: Missing parameter - source"
    exit 0
fi

if [[ $(File.isDirectory "$(pwd)/$1") ]]; then
    println "${RED}ERROR: $1 is a directory."
else
    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs w "$(pwd)/$1"
    if [[ ! $? == 0 ]]; then
        Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs r "$(pwd)/$1"
        if [[ ! $? == 0 ]]; then
            println "${YELLOW}WARNING: $1 is read-only file, so the file content is printed instead of opening in the editor."
            cat "$1"
        else
            println "${RED}ERROR: $1 is not readable nor writable."
            exit 0
        fi
    fi

    nano "$(pwd)/$1"
fi

