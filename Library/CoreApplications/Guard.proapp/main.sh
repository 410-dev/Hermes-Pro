#!/bin/bash

@import Hash/sha
@import Foundation/in
@import Foundation/out
@import Foundation/int
@import Hermes

# Check for password
# Parameter:
#  $1: User ID
#  $2: attempts
function checkPassword() {

    userID=$1
    int attempts=$2

    setSecureInputSalt "$(Hash.stringToSha 256 "${userName}")"
    secureInput "Enter a password: " userPassword
    println " "

    if [[ $(Hermes.pref "System.UserPassword_${userID}") == "$(Hash.stringToSha 256 "${userPassword}")" ]]; then
        s_log "Password correct."
        return 0
    else
        s_log "Password incorrect."
        # If the login attempt is 3 times, exit the script.
        if [[ ${attempts} == 3 ]]; then
            println "Unable to authenticate."
            return 20
        fi
        add attempts 1 attempts
        checkPassword "${userID}" "${attempts}"
        return $?
    fi
}



checkPassword "$1" 1
if [[ $? == 0 ]]; then
    exit 0
else
    s_log "Authentication failed."
    exit 1
fi