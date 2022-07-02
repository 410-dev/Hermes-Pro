#!/bin/bash

@import File
@import Foundation

# Get Container Name
input "Please enter container name: " containerName
if [[ $(File.isDirectory "$DEFAULT_VM_LOCATION/containers/$containerName") ]]; then
    println "${RED}Container already exists."
    exit 9
fi

# Get Image Path
input "Please input the system image file: " imageFileLoc
if [[ ! $(File.isFile "$imageFileLoc") ]]; then
    println "${RED}File not found."
    exit 9
fi

input "Please input the firmware file (optional): " firmwareFileLoc

input "Please specify boot file (optional): " bs

println "Setting things up..."

println "SETSTYLE: $(<"$DEFAULT_VM_LOCATION/extract_style")"
@include "$DEFAULT_VM_LOCATION/extract_style"

println "Creating container..."
File.createDirectory "$DEFAULT_VM_LOCATION/containers/$containerName/disk0"

println "Unpacking image..."
unzip -o -q "$imageFileLoc" -d "$DEFAULT_VM_LOCATION/containers/$containerName/disk0/$SYSTEM"

if [[ $(File.isDirectory "$DEFAULT_VM_LOCATION/containers/$containerName/disk0/$SYSTEM/__MACOSX") ]]; then
    File.removeDirectory "$DEFAULT_VM_LOCATION/containers/$containerName/disk0/$SYSTEM/__MACOSX"
fi

echo "Writing boot file..."

if [[ -z "$bs" ]]; then
    println "Boot file: $BOOTSECT"
    File.overwrite "$DEFAULT_VM_LOCATION/containers/$containerName/bootfile" "$BOOTSECT"
else
    println "Boot file: $bs"
    File.overwrite "$DEFAULT_VM_LOCATION/containers/$containerName/bootfile" "$bs"
fi

if [[ ! -z "$firmwareFileLoc" ]]; then
    println "Writing firmware..."
    File.copyFile "$firmwareFileLoc" "$DEFAULT_VM_LOCATION/containers/$containerName/"
fi
echo "Done!"
