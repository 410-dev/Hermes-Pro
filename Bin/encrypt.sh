#!/bin/bash
@import Hermes
@import Foundation
@import File/check
@import File/attribute
@import Security/aes-file

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

    Security.AES256FileEncrypt "$(pwd)/$1" "$3"
    if [[ ! $? == 0 ]]; then
        exit 0
    fi

    File.relocate "$(pwd)/$1.e" "$(pwd)/$2" "overwrite"
    if [[ ! $? == 0 ]]; then
        exit 0
    fi
else
    println "${RED}ERROR: $@ does not exist."
fi

