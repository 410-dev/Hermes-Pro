#!/bin/bash

# Rename $@ to $BOOTARGS
export BOOTARGS="$@"

# Directly start the foundation
while [[ true ]]; do

    clear


    # Load partition information
    source "$(dirname "$0")/Partitions"

    # Check if {SYSTEM}/Foundation/init exists
    if [[ -f "${SYSTEM}/Library/Foundation/init" ]]; then
        # Run the init script
        echo "Foundation: Running init script..."
        "${SYSTEM}/Library/Foundation/init"
        exitCode=$?

        # 0: Shutdown signal
        # 1: Restart signal
        # 2: Recovery signal
        # The rest is fail signal.

        if [[ $exitCode == 0 ]]; then
            # Shutdown signal
            exit $exitCode
        elif [[ $exitCode == 1 ]]; then
            # Restart signal
            continue
        elif [[ $exitCode == 2 ]]; then
            # Recovery signal
            continue
        else
            # If init failed, exit
            exit $exitCode
        fi
    else
        # If init does not exist, exit
        echo "${SYSTEM}/Library/Foundation/init not found."
        exit 1
    fi
done
