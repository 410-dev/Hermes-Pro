#!/bin/bash

# Import required components from the runtime
@import Hermes
@import Foundation/string
@import File/check
@import NullAction

# Check if the system is fully setup
# If not, run setup.proapp
if [[ $(Hermes.pref "System.setupComplete") ]]; then
    # System is already setup
    NullAction.doNothing
else
    # Run setup.proapp
    Hermes.appStart "${SYSTEM}/Library/CoreApplications/Setup.proapp"
    exitCode=$?

    # If setup failed, exit
    if [[ $exitCode != 0 ]]; then
        exit $exitCode
    fi
fi


# Launch Login shell
Hermes.appStart "${SYSTEM}/Library/CoreApplications/LoginShell.proapp"
exitCode=$?

# The exit codes:
#  100 - No application specified
#  101 - Not an application
#  102 - Application information is incomplete
#  
#  0 - Shutdown signal
#  1 - Restart signal
#  2 - Recovery signal
#  3..99 - User number

# Use the exit code user number to determine which user to log in as
# If exit code is either 0 or 1, then exit with the same code
if [[ $exitCode == 0 ]] || [[ $exitCode == 1 ]]; then
    exit $exitCode
fi

# If the exit code is in between 100 and 102, then exit with shutdown signal.
if [[ $exitCode -ge 100 ]] && [[ $exitCode -le 102 ]]; then
    exit 0
fi

# Get the user directory path from the exit code using preference function
userID=$(Hermes.pref "System.UserID_$exitCode")
userIDCheck=$?
userDir=$(Hermes.pref "System.UserHomeDirectory_$exitCode")
userDirCheck=$?

# If the user directory is not found, then exit with reboot signal
if [[ $userIDCheck == 2 ]] || [[ ! $(File.isDirectory "$userDir") ]]; then
    verbose_err "User directory \"$userDir\" not found!!"
    exit 1
fi


println "Welcome to Hermes!"
println "You are logged in as user $userID"
println "Your home directory is $userDir"

println " "
verbose "Running login script.."

# Run login scripts
cd "${userDir}/Library/LoginScript"
loginScripts="$(ls -p | grep -v / | grep ".sh")" 2>/dev/null

while read loginScript
do
    if [[ ! $(String.isNull "${loginScript}") ]]; then
        # Source it
        verbose "Running login script: ${loginScript}"
        chmod +x "${userDir}/Library/LoginScript/${loginScript}"
        print "${DARK_GRAY}"
        @include "${userDir}/Library/LoginScript/${loginScript}"
        exitStatus="$?"
        if [[ "${exitStatus}" != "0" ]]; then
            verbose_err "Failed running login script: ${loginScript}"
        fi
    fi
done <<< "$loginScripts"
print "${C_DEFAULT}"
unset loginScripts loginScript exitStatus

# Change the current directory to the user directory
cd "$userDir"

println "Type 'help' for a list of commands."

# Infinite Loop
# TODO