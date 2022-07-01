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
    verbose_err "Missing parameter - application name." "open"
    println "${RED}ERROR: Missing parameter - application name."
    exit 0
fi

files="$(File.list "${SYSTEM}/Applications")"
verbose "Searching from system applications..." "open"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        verbose "Found application: $file" "open"
        Hermes.appStart "${SYSTEM}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    else
        verbose_warn "Not matched: ${file}" "open"
    fi
done
verbose_warn "Not found from system applications." "open"

verbose "Searching from global applications..." "open"
files="$(File.list "${DATA}/Applications")"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        verbose "Found application: $file" "open"
        Hermes.appStart "${DATA}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    else
        verbose_warn "Not matched: ${file}" "open"
    fi
done
verbose_warn "Not found from global applications." "open"

verbose "Searching from user applications..." "open"
files="$(File.list "${userDir}/Applications")"
for file in $files; do
    file="$(String.replace "$file" ".proapp" "")"
    if [[ "$file" == "$1" ]]; then
        verbose "Found application: $file" "open"
        Hermes.appStart "${userDir}/Applications/${file}.proapp" "$@"
        if [[ ! $? == 0 ]]; then
            exit 0
        fi
        exit 0
    else
        verbose_warn "Not matched: ${file}" "open"
    fi
done

verbose_warn "Not found from user applications." "open"
verbose_err "Application $1 not found." "open"
println "${RED}ERROR: Application not found."
