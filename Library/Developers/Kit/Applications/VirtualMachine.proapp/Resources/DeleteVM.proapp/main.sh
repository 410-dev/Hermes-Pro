#!/bin/bash

@import Hermes
@import Foundation

input "Please enter container name: " containerName

if [[ -z "$containerName" ]]; then
    println "Container is not specified."
else
    verbose "Deleting container: $containerName" "DeleteVM"
    if [[ -d "$DEFAULT_VM_LOCATION/containers/$containerName" ]]; then
        rm -rf "$DEFAULT_VM_LOCATION/containers/$containerName"
        verbose "Deleted container: $containerName" "DeleteVM"
        println "Container deleted."
    else
        verbose_err "Container not found: $containerName" "DeleteVM"
        println "Container not found."
    fi
fi
