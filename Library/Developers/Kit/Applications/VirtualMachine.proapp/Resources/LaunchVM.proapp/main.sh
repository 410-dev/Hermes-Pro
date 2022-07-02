#!/bin/bash

@import Hermes
@import Foundation

input "Please enter container name: " containerName
input "Please enter boot arguments: " BOOTARGS

if [[ -z "$containerName" ]]; then
    verbose_err "Container is not specified." "LaunchVM"
    println "${RED}Container is not specified."
else
    if [[ -d "$DEFAULT_VM_LOCATION/containers/$containerName" ]]; then
        println "Starting container: $containerName"
        verbose "Starting container: $containerName" "LaunchVM"
        cd "$DEFAULT_VM_LOCATION/containers/$containerName"
        verbose "Set working directory to: $(pwd)" "LaunchVM"
        export bootf="$(<"./bootfile")"
        verbose "Boot file: $bootf" "LaunchVM"
        unset DEFAULT_VM_LOCATION
        verbose "Unset DEFAULT_VM_LOCATION" "LaunchVM"
        cd "./disk0"
        verbose "Set working directory to: $(pwd)" "LaunchVM"
        verbose "Launching container..." "LaunchVM"
        "$bootf" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    else
        verbose_err "Container not found." "LaunchVM"
        println "${RED}Container not found."
    fi
fi