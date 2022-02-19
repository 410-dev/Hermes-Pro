#!/bin/bash


# Load runtime
source "${SYSTEM}/Library/Foundation/runtime/loader" "${SYSTEM}/Library/Foundation/runtime/"

# Import required components from the runtime
@import Hermes/system
@import Hermes/application
@import Foundation/string
@import File/check
@import File/remove

# 
# Load Drivers
# Drivers: Library/Foundation/drivers/<driver>.hdrv
#       It loads memory data for hardware control. All functions are exported from the driver.
# 

# All drivers are expected to be a bundle with extension of .hdrv, with the following contents.
#  - A binary file named "driver"
#  - A file named "INF" - containing the driver information in the following format:
#      <driver name>
#      <driver version>
#      <driver author>
#      <driver description>
cd "${SYSTEM}/Library/Drivers"
drivers="$(ls | grep ".hdrv")" 2>/dev/null
verbose "Loading drivers..."
verbose "Drivers list: $drivers"

while read driver
do
	if [[ ! $(String.isNull "${driver}") ]]; then
        verbose "Loading driver: ${driver}"

        # Load information
        @include "${SYSTEM}/Library/Drivers/${driver}"/INF

        # Check if the driver information is filled
        if [[ $(String.isNull "${DRVNAME}") ]] || [[ $(String.isNull "${DRVVER}") ]] || [[ $(String.isNull "${DRVAUTHOR}") ]] || [[ $(String.isNull "${DRVDESCRIPTION}") ]]; then
            verbose_err "Driver information for \"${driver}\" is incomplete!"
            continue
        else
            verbose "Driver information: ${DRVNAME} (v.${DRVVER}) by ${DRVAUTHOR}"
        fi

        # Load actual driver
        @include "${SYSTEM}/Library/Drivers/${driver}/driver"
        exitStatus="$?"

        # If the driver failed to load, then invoke panic
        if [[ "${exitStatus}" != "0" ]]; then
            verbose_err "Failed to load driver: ${driver}"
            "${SYSTEM}/Library/Foundation/panic" halt
        fi
        
        loadedDrivers+=("${SYSTEM}/Library/Drivers/${driver}")
	fi
done <<< "$drivers"

# Write the loaded drivers to the CACHE/drivers.ldlist file
verbose "Writing loaded drivers to CACHE/drivers.ldlist"
SVIFS=$IFS
IFS=$'\n'
File.overwrite "${CACHE}/drivers.ldlist" "${loadedDrivers[*]}"
IFS=$SVIFS

unset drivers driver

# 
# Load extensions
# Extensions: Library/Foundation/extensions/<extension>.hext
#       It loads memory data for further hardware control or patches. All functions are exported from the extension.
# 

# All extensions are expected to be a bundle with extension of .hext, with the following contents.
#  - A binary file named "extension"
#  - A file named "INF" - containing the extension information in the following format:
#      <extension name>
#      <extension version>
#      <extension author>
#      <extension description>
cd "${SYSTEM}/Library/Extensions"
extensions="$(ls | grep ".hext")" 2>/dev/null
verbose "Loading extensions..."
verbose "Extensions list: $extensions"

while read extension
do
    if [[ ! $(String.isNull "${extension}") ]]; then
        verbose "Loading extension: ${extension}"

        # Load information
        @include "${SYSTEM}/Library/Extensions/${extension}"/INF

        # Check if the extension information is filled
        if [[ $(String.isNull "${EXTNAME}") ]] || [[ $(String.isNull "${EXTVER}") ]] || [[ $(String.isNull "${EXTAUTHOR}") ]] || [[ $(String.isNull "${EXTDESCRIPTION}") ]]; then
            verbose_err "Extension information for \"${extension}\" is incomplete!"
            continue
        else
            verbose "Extension information: ${EXTNAME} (v.${EXTVER}) by ${EXTAUTHOR}"
        fi

        # Load actual extension
        @include "${SYSTEM}/Library/Extensions/${extension}/extension"
        exitStatus="$?"
        
        # Check if the extension loaded successfully
        if [[ "${exitStatus}" != "0" ]]; then

            # If the extension failed to load, invoke panic
            verbose_err "Failed to load extension: ${extension}"
            "${SYSTEM}/Library/Foundation/panic" halt
        fi
        loadedExtensions+=("${SYSTEM}/Library/Extensions/${extension}")
    fi
done <<< "$extensions"

# Write the loaded extensions to the CACHE/extensions.ldlist file
verbose "Writing loaded extensions to CACHE/extensions.ldlist"
SVIFS=$IFS
IFS=$'\n'
File.overwrite "${CACHE}/extensions.ldlist" "${loadedExtensions[*]}"
IFS=$SVIFS

unset extensions extension


# 
# Load background services asynchronously
# Background Service: Library/Services/<service>.hsvc
#         It runs in background asynchronously.
# 

# Because background service is asynchronous, the program requires stopping code for certain conditions.
# For example, if the program is running in a loop, it needs to be stopped.
# The function async_thread() is used to stop the program when there's shutdown signal.
function async_thread() {

    # Create directory that stores async thread information
    File.createDirectory "${CACHE}/OS.AsyncThreads.infd"

    # Create file that stores the thread information
    File.getName "${1}" threadName
    File.overwirte "${CACHE}/OS.AsyncThreads.infd/${threadName}" "RUNNING, ${1}"

    # Background service must stay in loop
    while [[ true ]]; do

        # Check if there is stop signal
        if [[ $(File.isFile "${STOPSIG}") ]]; then
            # Stop the program
            verbose "Stopping background service."
            break
        fi
        
        # Execute the service
        if [[ ! $(String.isNull "$1") ]] && [[ $(File.isFile "$1") ]]; then
            "$1"
            exitStatus="$?"

            # If the service is stopped, break the loop
            if [[ "${exitStatus}" != "0" ]]; then
                s_log "Failed to execute background service: $1"
                break
            fi
        fi

        # Sleep for a while
        if [[ ! $(String.isNull "$2") ]]; then
            sleep "$2"
        else
            sleep 1
        fi

    done

    # Set thread status to stopped
    File.overwrite "${CACHE}/OS.AsyncThreads.infd/${threadName}" "EXIT, ${1}"
}

# Run background service
cd "${SYSTEM}/Library/Services"
services="$(ls -p | grep -v / | grep ".hasv")" 2>/dev/null

while read service
do
    if [[ ! $(String.isNull "${service}") ]]; then
        # Launch it
        verbose "Loading service: ${service}"

        # Load information components.
        # Information file (INF) must contain:
        #    - Service name
        #    - Service description
        #    - Service author
        #    - Service version
        #    - Service loop delay
        @include "${SYSTEM}/Library/Services/${service}.hasv/INF"
        async_thread "${SYSTEM}/Library/Services/${service}.hasv/main" ${LOOP_DELAY} & >/dev/null 2>/dev/null
    fi
done <<< "$services"
unset services service


# 
# System preparation is completed at this point.
# Shell is ready to run.
# 
Hermes.appStart "${SYSTEM}/Library/CoreApplications/Shell.proapp"
File.removeDirectory "${CACHE}"
exit $?