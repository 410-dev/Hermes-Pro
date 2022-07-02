#!/bin/bash

@import Foundation
@import File/new
@import Hermes
@import File

@include "$1/virtualmachinedefaultlocation"

# Create VM location
if [[ "$(File.isDirectory "$DEFAULT_VM_LOCATION")" ]]; then
    verbose "Using default VM location: $DEFAULT_VM_LOCATION" "VirtualMachine"
else
    verbose_warn "Default VM location does not exist: $DEFAULT_VM_LOCATION" "VirtualMachine"
    verbose "Creating default VM location: $DEFAULT_VM_LOCATION" "VirtualMachine"
    File.createDirectory "$DEFAULT_VM_LOCATION"
    File.createDirectory "$DEFAULT_VM_LOCATION/containers"
    File.createDirectory "$DEFAULT_VM_LOCATION/extensions"
    File.overwrite "$DEFAULT_VM_LOCATION/extract_style" "export SYSTEM=\"System\"; export BOOTSECT=\"System/boot/init\""
    verbose "Created default VM location: $DEFAULT_VM_LOCATION" "VirtualMachine"
fi


# TODO: Use arguments to automatically set the application name and its action

while [[ true ]]; do
    println "Select menu: "
    println "1. Create VM"
    println "2. Delete VM"
    println "3. List VM"
    println "4. Launch VM"
    println "5. Exit"
    println ""
    input "Select menu: " menu

    if [ $menu -eq 1 ]; then
        Hermes.appStart "$1/Resources/MakeVM.proapp"
    elif [ $menu -eq 2 ]; then
        Hermes.appStart "$1/Resources/DeleteVM.proapp"
    elif [ $menu -eq 3 ]; then
        Hermes.appStart "$1/Resources/ListVM.proapp"
    elif [ $menu -eq 4 ]; then
        Hermes.appStart "$1/Resources/LaunchVM.proapp"
    elif [ $menu -eq 5 ]; then
        break
    else
        println "Invalid menu."
    fi
done