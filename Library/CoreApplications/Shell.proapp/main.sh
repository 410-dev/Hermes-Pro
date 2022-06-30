#!/bin/bash

# Import required components from the runtime
@import File/remove
@import Hermes
@import Foundation
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
export userName=$(Hermes.pref "System.UserID_$exitCode")
export userNumID=$exitCode
userIDCheck=$?
export userDir=$(Hermes.pref "System.UserHomeDirectory_$exitCode")
userDirCheck=$?

# If the user directory is not found, then exit with reboot signal
if [[ $userIDCheck == 2 ]] || [[ ! $(File.isDirectory "$userDir") ]]; then
    verbose_err "User directory \"$userDir\" not found!!"
    exit 1
fi

machineName=$(Hermes.pref "System.MachineName")
export userPermission=$(Hermes.pref "System.UserPermission_$exitCode")

println "Welcome to Hermes!"

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
while [[ true ]]; do

    # Shell Commands
    # pwr_restart - Restart the system
    # pwr_shutdown - Shutdown the system
    # pwr_recovery - Reboot into recovery mode
    # privilage - Elevate the user's privileges
    # sh_changedirectory - Change the current directory


    # Read shell command
    ShellCommand="$(shellCommandRead)"

    # Loop through every lines
    while read line; do
        # If the line is not empty, then execute it
        if [[ ! $(String.isNull "${line}") ]]; then
            s_log "[Shell.proapp] Executing command: ${line}"
            
            # Execute the command
            if [[ "${line}" == "pwr_restart" ]]; then
                s_log "[Shell.proapp] Restarting system due to shellCommand request..."
                exit 1
            elif [[ "${line}" == "pwr_shutdown" ]]; then
                s_log "[Shell.proapp] Shutting down system due to shellCommand request..."
                exit 0
            elif [[ "${line}" == "pwr_recovery" ]]; then
                s_log "[Shell.proapp] Rebooting into recovery mode due to shellCommand request..."
                exit 2
            elif [[ "${line}" == "privilage "* ]]; then
                s_log "[Shell.proapp] Temporarily upgrading user's permission..."
                userPermission=${line#privilage }
                verbose "User permission upgraded to: ${userPermission}"
            elif [[ "${line}" == "sh_changedirectory "* ]]; then
                s_log "[Shell.proapp] Changing directory due to shellCommand request..."

                # Get the directory
                dirPath="${line#sh_changedirectory }"
                verbose "Changing directory to: ${dirPath}"

                # Check if the directory exists
                if [[ "$(File.isDirectory "$dirPath")" ]]; then
                    # Change the directory
                    cd "$dirPath"
                else
                    # Directory does not exist
                    s_log "[Shell.proapp] Directory does not exist: ${dirPath}"
                fi
            fi
        fi
    done <<< "$ShellCommand"


    # Print notification
    shellNotify

    # Read the command
    input "${userName}@${machineName}: " command
    
    # Check if the command is empty
    if [[ $(String.isNull "${command}") ]]; then
        continue
    fi

    # Split by space
    String.split "${command}" " " commandArray

    # Load paths from preference
    pathList=$(Hermes.userpref ${userNumID} "System.CommandPaths")

    # Split paths by semicolon
    String.split "${pathList}" ";" pathArray

    # Loop through every pathArray
    for (( i=0; i<${#pathArray[@]}; i++ )); do
        # Check if the path is not empty
        if [[ $(String.isNull "${pathArray[$i]}") ]]; then
            s_log "[Shell.proapp] Path is empty"
            continue
        fi

        # Check if the path is a directory
        if [[ ! $(File.isDirectory "${pathArray[$i]}") ]]; then
            s_log "[Shell.proapp] Path is not a directory: ${pathArray[$i]}"
            continue
        fi

        # Check if the command is in the directory
        if [[ $(File.isFile "${pathArray[$i]}/${commandArray[0]}") ]]; then
            # Execute the command
            verbose "Executing command: ${commandArray[0]}"
            s_log "[Shell.proapp] Executing command: ${commandArray[0]}"
            
            "${pathArray[$i]}/${commandArray[0]}" "${commandArray[@]:1}"
            exitStatus="$?"

            # Check if the exit status is not 0
            if [[ "${exitStatus}" != "0" ]]; then
                verbose_err "Failed running command: ${commandArray[0]}"
            fi
            unset exitStatus

            # Break the loop
            found=1
            break
        fi
    done

    # Check if the command was found
    if [[ ! $found ]]; then
        s_log "[Shell.proapp] Command not found: ${commandArray[0]}"
        println "${RED}Command not found: ${commandArray[0]}"
    fi
    unset found
done