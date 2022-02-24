#!/bin/bash

# Parameter
# 1: Bundle path (Automatically done by Hermes.appStart)
# 2: Verb (exec, fs)
# 3: Mode
# 4: Path

@import Hash/sha
@import Foundation/in
@import Foundation/out
@import Foundation/int
@import File/check
@import File/name
@import Hermes

# Check for password
# Parameter:
#  $1: attempts
function checkPassword() {

    userID=${userNumID}
    int attempts=$2

    setSecureInputSalt "$(Hash.stringToSha 256 "${userName}")"
    secureInput "Enter a password: " userPassword
    println " "

    if [[ $(Hermes.pref "System.UserPassword_${userID}") == "$(Hash.stringToSha 256 "${userPassword}")" ]]; then
        s_log "[Guard] Password correct."
        return 0
    else
        s_log "[Guard] Password incorrect."
        # If the login attempt is 3 times, exit the script.
        if [[ ${attempts} == 3 ]]; then
            println "${RED}Unable to authenticate."
            return 20
        fi
        add attempts 1 attempts
        checkPassword "${attempts}"
        return $?
    fi
}



# Parameter:
#  $1: Bundle path
#  $2: user permission
#  $3: Mode
#  $4: Path
# 
# Return:
#  0 - Success
#  1 - Prohibited
function fsCheck() {
    bundlePath="$1"
    mode="$3"
    queryPath="$4"

    s_log "[Guard] User has permission of ${userPermission} and action is ${mode}."
    s_log "[Guard] Scanning entitlements..."
    s_log "[Guard] Checking if the query path is valid..."

    # Check if the query path is file or directory
    if [[ ! $(File.isDirectory "${queryPath}") ]]; then
        queryPath="$(File.getDirectoryOf "${queryPath}")"
    fi

    WORKING="$(pwd)"
    cd "${queryPath}"
    queryPath="$(pwd)"
    cd "${WORKING}"

    s_log "[Guard] Query path is ${queryPath}."

    # If it tries to escape the disk, stop it.
    if [[ $(isFrontGreater ${#ROOTFS} ${#queryPath}) ]]; then
        s_log "[Guard] Operation not permitted."
        println "${RED}Operation not permitted."
        return 1
    fi

    # If the user has highest permission and action is reading, then return success regardless of path
    if [[ "$userPermission" == 0 ]] && [[ "$mode" == "READ" ]]; then
        s_log "[Guard] Operation permitted."
        return 0
    fi

    # Get the entitlements
    if [[ "$userPermission" == 0 ]]; then
        # If the user has highest permission, then check only write mode
        # If the user with highest permission tries to write to system directory, stop it.
        if [[ "$mode" == "WRITE" ]] && [[ "$queryPath" == "${SYSTEM}/"* ]]; then
            s_log "[Guard] Operation not permitted."
            println "${RED}Operation not permitted."
            return 1
        fi
        s_log "[Guard] Operation permitted."
        return 0
    elif [[ "$userPermission" == 10 ]]; then
        # Check both read and write mode.
        # If the user with permission of 10 tries to write to /, /System, /Data/Preferences, /NVRAM, stop it.
        if [[ "$mode" == "WRITE" ]]; then
            if [[ "$queryPath" == "${SYSTEM}/"* ]] || [[ "$queryPath" == "${SYSTEM}" ]] || 
            [[ "$queryPath" == "${ROOTFS}" ]] || 
            [[ "$queryPath" == "${DATA}/Preferences/"* ]] || [[ "$queryPath" == "${DATA}/Preferences" ]] || 
            [[ "$queryPath" == "${ROOTFS}/NVRAM/"* ]] || [[ "$queryPath" == "${ROOTFS}/NVRAM" ]]; then
                s_log "[Guard] Operation not permitted."
                println "${RED}Operation not permitted."
                return 1
            fi
        fi

        # If the user with permission of 10 tries to read /System, stop it.
        if [[ "$mode" == "READ" ]]; then
            if [[ "$queryPath" == "${SYSTEM}/"* ]] || [[ "$queryPath" == "${SYSTEM}" ]]; then
                s_log "[Guard] Operation not permitted."
                println "${RED}Operation not permitted."
                return 1
            fi
        fi
        return 0
    fi

}


if [[ "$2" == "exec" ]]; then
    s_log "[Guard] Task execution authentication started."
    checkPassword 1
    if [[ $? == 0 ]]; then
        exit 0
    else
        s_log "[Guard] Authentication failed."
        exit 1
    fi
elif [[ "$2" == "fs" ]]; then
    s_log "[Guard] File system authentication started."
    if [[ "$3" == "r" ]]; then
        s_log "[Guard] Access mode: READ"
        fsCheck "$1" "$2" "READ" "$4"
    elif [[ "$3" == "w" ]]; then
        s_log "[Guard] Access mode: WRITE"
        fsCheck "$1" "$2" "WRITE" "$4"
    fi
else
    s_log "[Guard] Unknown task: $2"
    exit 1
fi