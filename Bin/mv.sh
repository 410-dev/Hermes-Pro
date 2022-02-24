#!/bin/bash
@import Hermes
@import Foundation
@import File/check

if [[ $(String.isNull $1) ]]; then
    println "${RED}ERROR: Missing parameter - source"
    exit 0
elif [[ $(String.isNull $2) ]]; then
    println "${RED}ERROR: Missing parameter - destination"
    exit 0
fi


if [[ $(File.exists "$(pwd)/$1") ]]; then

    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs r "$(pwd)/$2"
    if [[ ! $? == 0 ]]; then
        exit 0
    fi
    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Guard.proapp" fs w "$(pwd)/$2"
    if [[ ! $? == 0 ]]; then
        exit 0
    fi

    mv "$(pwd)/$1" "$(pwd)/$2"
else
    println "${RED}ERROR: $@ does not exist."
fi

