#!/bin/bash

# Open application.
# @param $1 - Application name.
# @param $@ - Application parameters.
# @return 0 - Success.
# @return 1 - Failure.

@import Foundation/out
@import Foundation/string
@import Hermes/application
@import File/list

if [[ $(String.isNull "$1") ]]; then
    println "${RED}ERROR: Missing parameter - application name."
    exit 0
fi

files="$(File.list "${SYSTEM}/Applications")"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        Hermes.appStart "${SYSTEM}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    fi
done

files="$(File.list "${DATA}/Applications")"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        Hermes.appStart "${DATA}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    fi
done

files="$(File.list "${userDir}/Applications")"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        Hermes.appStart "${userDir}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    fi
done

println "${RED}ERROR: Application not found."
