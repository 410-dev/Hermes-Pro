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
        verbose "Password correct." "Guard"
        return 0
    else
        verbose_err "Password incorrect." "Guard"
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

    verbose "User has permission of ${userPermission} and action is ${mode}." "Guard"
    verbose "Scanning entitlements..." "Guard"
    verbose "Checking if the query path is valid..." "Guard"

    # Check if the query path is file or directory
    if [[ ! $(File.isDirectory "${queryPath}") ]]; then
        queryPath="$(File.getDirectoryOf "${queryPath}")"
    fi

    WORKING="$(pwd)"
    cd "${queryPath}"
    queryPath="$(pwd)"
    cd "${WORKING}"

    verbose "Query path is ${queryPath}." "Guard"

    # If it tries to escape the disk, stop it.
    if [[ $(isFrontGreater ${#ROOTFS} ${#queryPath}) ]]; then
        verbose_err "Operation not permitted." "Guard"
        println "${RED}Operation not permitted."
        return 1
    fi

    # If the user has highest permission and action is reading, then return success regardless of path
    if [[ "$userPermission" == 0 ]] && [[ "$mode" == "READ" ]]; then
        verbose "Operation permitted." "Guard"
        return 0
    fi

    # Get the entitlements
    if [[ "$userPermission" == 0 ]]; then
        # If the user has highest permission, then check only write mode
        # If the user with highest permission tries to write to system directory, stop it.
        if [[ "$mode" == "WRITE" ]] && [[ "$queryPath" == "${SYSTEM}/"* ]]; then
            verbose_err "Operation not permitted." "Guard"
            println "${RED}Operation not permitted."
            return 1
        fi
        verbose "Operation permitted." "Guard"
        return 0
    elif [[ "$userPermission" == 10 ]]; then
        # Check both read and write mode.
        # If the user with permission of 10 tries to write to /, /System, /Data/Preferences, /NVRAM, stop it.
        if [[ "$mode" == "WRITE" ]]; then
            if [[ "$queryPath" == "${SYSTEM}/"* ]] || [[ "$queryPath" == "${SYSTEM}" ]] || 
            [[ "$queryPath" == "${ROOTFS}" ]] || 
            [[ "$queryPath" == "${DATA}/Preferences/"* ]] || [[ "$queryPath" == "${DATA}/Preferences" ]] || 
            [[ "$queryPath" == "${ROOTFS}/NVRAM/"* ]] || [[ "$queryPath" == "${ROOTFS}/NVRAM" ]]; then
                verbose_err "Operation not permitted." "Guard"
                println "${RED}Operation not permitted."
                return 1
            fi
        fi

        # If the user with permission of 10 tries to read /System, stop it.
        if [[ "$mode" == "READ" ]]; then
            if [[ "$queryPath" == "${SYSTEM}/"* ]] || [[ "$queryPath" == "${SYSTEM}" ]]; then
                verbose_err "Operation not permitted." "Guard"
                println "${RED}Operation not permitted."
                return 1
            fi
        fi
        return 0
    fi

}


if [[ "$2" == "exec" ]]; then
    verbose "Task execution authentication started." "Guard"
    checkPassword 1
    if [[ $? == 0 ]]; then
        exit 0
    else
        verbose_err "Authentication failed." "Guard"
        exit 1
    fi
elif [[ "$2" == "fs" ]]; then
    verbose "File system authentication started." "Guard"
    if [[ "$3" == "r" ]]; then
        verbose "Access mode: READ" "Guard"
        fsCheck "$1" "$2" "READ" "$4"
    elif [[ "$3" == "w" ]]; then
        verbose "Access mode: WRITE" "Guard"
        fsCheck "$1" "$2" "WRITE" "$4"
    fi
else
    verbose_err "Unknown task: $2" "Guard"
    exit 1
fi