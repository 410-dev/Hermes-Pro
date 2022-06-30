#!/bin/bash

@import Network/get
@import Hermes
@import Foundation/out
@import Foundation/in


# TODO:TEST

# Update channel codes:
# main - Main channel (Stable)
# beta - Beta channel (Unstable)


# Get update channel from preference
UPDATECHANNEL=$(Hermes.pref "System.UpdateUtility.Channel")

# Get update channel URL
UPDATEURL="https://raw.githubusercontent.com/410-dev/Hermes-Pro/${UPDATECHANNEL}/latest"

# Get latest version from update channel
println "Checking update..."
Network.getHTML "${UPDATEURL}/version" LATEST_VERSION

# Compare with current version
if [[ "${OS_BUILD}" == "${LATEST_VERSION}" ]]; then
    if [[ ! "$1" == "silent" ]]; then
        println "Hermes Pro is up to date."
    else
        s_log "Hermes Pro is up to date."
    fi
    exit 0
else
    if [[ ! "$1" == "silent" ]]; then
        println "Hermes Pro is not up to date."
    else
        s_log "Hermes Pro is not up to date."
    fi
fi

# If silent mode is not enabled, ask user to update
if [[ ! "$1" == "silent" ]]; then
    input "Would you like to update now? (y/n)" update
    if [[ "${update}" == "y" ]] || [[ "${update}" == "Y" ]]; then
        println "Starting update..."
    else
        exit 0
    fi
else
    s_log "Silent mode enabled. Downloading update in background."
fi

# Download update
if [[ ! "$1" == "silent" ]]; then
    println "Downloading update..."
    Network.saveDocument "https://github.com/410-dev/Hermes-Pro/releases/download/${LATEST_VERSION}/image.zip" "${LIBRARY}/Updates/image_${LATEST_VERSION}.zip" --progress-bar
    File.overwrite "${LIBRARY}/Updates/version" "${LATEST_VERSION}"
    println "Download complete."

    # Ask user to install update
    input "Would you like to install the update now? (y/n)" update
    if [[ "${update}" == "y" ]] || [[ "${update}" == "Y" ]]; then
        println "Installing update..."

        # Write data to preference so that the update utility knows that the update should be installed on boot
        Hermes.pref "System.UpdateUtility.RunOnBootUpdate" "true"

        # Ask shell to restart
        println "Restarting shell..."

        # Restart shell
        shellCommand "pwr_restart"
        exit 0
    else
        exit 0
    fi
else
    Network.saveDocument "https://github.com/410-dev/Hermes-Pro/releases/download/${LATEST_VERSION}/image.zip" "${LIBRARY}/Updates/image_${LATEST_VERSION}.zip"
    File.overwrite "${LIBRARY}/Updates/version" "${LATEST_VERSION}"
    shellNotify "Hermes Pro update (${LATEST_VERSION}) found and is ready to be installed."
fi