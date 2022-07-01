#!/bin/bash

@import Hermes
@import Foundation
@import File/check
@import Hash/sha

# If there is no user (user count = 0) or required to create a new user, then create a new user.
isUserSetupComplete=$(Hermes.pref "System.UserCounts")
if [[ ${isUserSetupComplete} == 0 ]] || [[ "$2" == "newUserAccount" ]]; then
    # Create a new user
    dousersetup=true
    s_log "[LoginShell.proapp] Creating a new user..."
    
    while [[ true ]]; do
        input "Enter a new username: " userName

        # If the user name is empty, then throw an error.
        if [[ $(String.isNull "${userName}") ]]; then
            println "Username cannot be empty."
        
        # If the user name contains space, then throw an error. (Username will be used as user directory name.)
        elif [[ $(String.contains "${userName}" " ") ]]; then
            println "Username cannot contain spaces."

        # Verify if the user name is already taken.
        elif [[ $(File.isDirectory "${userName}") ]]; then
            println "User name already taken."

        # If the user name is valid, then start registration procedure
        else

            # Re-enter username
            input "Re-enter the new username: " userName2

            # If they are the same, then continue
            if [[ ${userName} == ${userName2} ]]; then

                # Set salt with the username
                setSecureInputSalt "$(Hash.stringToSha 256 "${userName}")"
                break
            else
                println "Username does not match. Please try again."
            fi
        fi
    done

    # Setup password
    while [[ true ]]; do
        secureInput "Enter a new password: " userPassword
        println " "
        secureInput "Re-enter the new password: " userPassword2
        println " "
        if [[ ${userPassword} == ${userPassword2} ]]; then
            break
        else
            println "Password does not match. Please try again."
        fi
    done


    # Agree to the legal statement
    println "Before we begin, you must agree to the following legal statement:"
    println " "
    File.readString "${SYSTEM}/Library/legal" LEGAL
    println "${LEGAL}"
    println " "
    println "Please type 'yes' to agree to the statement above."
    println " "
    input "Do you agree to the statement above? : " AGREE
    if [[ ! "${AGREE}" == "yes" ]]; then
        println "You must agree to the legal statement to continue."
        exit 0
    fi

    # Ask if the user wants to be hidden
    while [[ true ]]; do
        input "Do you want to be hidden? (y/n) [n]: " userHidden
        if [[ ${userHidden} == "y" ]] || [[ ${userHidden} == "Y" ]]; then
            break
        elif [[ ${userHidden} == "n" ]] || [[ ${userHidden} == "N" ]]; then
            break
        else
            println "Automatically considered as no."
            userHidden="n"
        fi
    done

    println "Setting things up..."

    # Call the init script
    verbose "Creating user directory..." "LoginShell.proapp"
    "$1/Resources/userDirectorySetup" "$userName" "${USERS}/${userName}"

    # Setup user preferences
    verbose "Setting up user preferences..." "LoginShell.proapp"

    # Update user count
    verbose "Updating user count..." "LoginShell.proapp"
    int userCounts=0
    add "${userCounts}" 1 userCounts
    verbose "User count: ${userCounts}" "LoginShell.proapp"
    Hermes.pref "System.UserCounts" "${userCounts}"
    verbose "User count updated." "LoginShell.proapp"

    # User identifiable integer ID
    verbose "Setting up user ID..." "LoginShell.proapp"
    int userNumID=$userCounts
    add "${userNumID}" 2 userNumID
    Hermes.pref "System.UserHomeDirectory_${userNumID}" "${USERS}/${userName}"
    verbose "User home directory set." "LoginShell.proapp"
    verbose "User ID: ${userNumID}" "LoginShell.proapp"
    verbose "Setting global user ID..." "LoginShell.proapp"
    Hermes.pref "System.UserID_${userNumID}" "${userName}"
    verbose "Setting user NID..." "LoginShell.proapp"
    Hermes.userpref "${userNumID}" "System.UserNumID" "${userNumID}"
    verbose "User ID set." "LoginShell.proapp"
   

    # Set user password
    verbose "Setting up user password..." "LoginShell.proapp"
    Hermes.pref "System.UserPassword_${userNumID}" "$(Hash.stringToSha 256 "${userPassword}")"
    verbose "User password set." "LoginShell.proapp"


    # Set user permission
    verbose "Setting up user permission..." "LoginShell.proapp"
    Hermes.pref "System.UserPermission_${userNumID}" "10"
    verbose "User permission set." "LoginShell.proapp"

    # Set user hidden
    verbose "Setting up user hidden/nohidden..." "LoginShell.proapp"
    if [[ ${userHidden} == "y" ]] || [[ ${userHidden} == "Y" ]]; then
        verbose "User hidden." "LoginShell.proapp"
        Hermes.pref "System.UserHidden_${userNumID}" "true"
    else
        verbose "User visible." "LoginShell.proapp"
        Hermes.pref "System.UserHidden_${userNumID}" "false"
    fi

    # Set legal flag
    verbose "Setting up user legal flag..." "LoginShell.proapp"
    Hermes.userpref "${userNumID}" "System.UserLegalFlag" "${AGREE}"

    # Set command paths for the user
    verbose "Setting up user command paths..." "LoginShell.proapp"
    Hermes.userpref "${userNumID}" "System.CommandPaths" "${SYSTEM}/Bin;"

    # Set user setup done
    Hermes.userpref "${userNumID}" "System.UserSetupDone" "true"
    verbose "User setup done flag wrote." "LoginShell.proapp"

    # Return the login code
    exit ${userNumID}
fi

# Otherwise, enter login procedure.
if [[ $dousersetup != "true" ]]; then
    # Enter login procedure
    s_log "Entering login procedure..."

    # Get user count
    userCounts=$(Hermes.pref "System.UserCounts")

    # If there is no user, then enter recovery.
    if [[ ${userCounts} == 0 ]]; then
        println "No user found."
        exit 2
    fi


    # Get list of user ID
    int userid=3
    int maxUserID=${userCounts}
    add "${maxUserID}" 2 maxUserID
    verbose "Max user ID: ${maxUserID}" "LoginShell.proapp"
    while [[ $(isFrontLesser ${userid} ${maxUserID}) ]] || [[ ${userid} == ${maxUserID} ]]; do
        userName=$(Hermes.pref "System.UserID_${userid}")
        if [[ $(Hermes.pref "System.UserHidden_${userid}") == "false" ]]; then
            verbose "User ${userName} is visible." "LoginShell.proapp"
            userIDList+=(${userid})
            userNameList+=(${userName})
        elif [[ $(Hermes.pref "System.UserHidden_${userid}") == "true" ]]; then
            verbose "User ${username} is hidden." "LoginShell.proapp"
            hiddenUserIDList+=(${userid})
            hiddenUserNameList+=(${userName})
        fi
        add "${userid}" 1 userid
    done

    # Show the list of users
    s_log "Showing user list..."
    println "User list:"
    int i=0
    while [[ $(isFrontLesser ${i} ${#userNameList[@]}) ]]; do
        int index=$i
        add "${index}" 1 index
        println " ${index}. ${userNameList[$i]}"
        add "${i}" 1 i
    done
    add "${i}" 1 i
    println " ${i}. [Others]"
    othersOption="${i}"
    add "${i}" 1 i
    println " ${i}. [Shutdown]"
    shutdownOption="${i}"
    add "${i}" 1 i
    println " ${i}. [Reboot]"
    rebootOption="${i}"


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
            # If the login attempt is 5 times, then shutdown the system.
            if [[ ${attempts} == 5 ]]; then
                println "Unable to continue login procedure. Shutting down system."
                exit 0
            fi
            add attempts 1 attempts
            checkPassword "${userID}" "${attempts}"
            return $?
        fi
    }


    # Ask for user selection

    while [[ true ]]; do
        input "Select a user: " userSelection
        int numlist=${#userNameList[@]}
        add "${numlist}" 1 numlist
        if [[ ${userSelection} == ${othersOption} ]]; then
            # Select others

            input "Enter a username: " userName
            
            # Check if the user exists
            int i=0
            while [[ $(isFrontLesser ${i} ${#hiddenUserNameList[@]}) ]]; do
                if [[ ${hiddenUserNameList[$i]} == ${userName} ]]; then
                    found=true
                    break
                fi
                add "${i}" 1
            done

            # If user exists, then ask for password
            if [[ ${found} ]]; then
                s_log "User ${userName} found."
                subtract $userSelection 1 userSelection
                checkPassword "${hiddenUserIDList[$i]}" 1
                status=$?
                if [[ $status == 0 ]]; then
                    exit ${hiddenUserIDList[$i]}
                else
                    exit $status
                fi
            else
                println "User ${userName} not found."
            fi

        # User selected
        elif [[ $(isFrontLesser ${userSelection} ${numlist}) ]] || [[ ${userSelection} == ${numlist} ]]; then

            # User selected
            subtract $userSelection 1 userSelection
            println "User selected: ${userNameList[$userSelection]}"
            checkPassword "${userIDList[$userSelection]}" 1
            println " "
            status=$?
            if [[ $status == 0 ]]; then
                exit ${userIDList[$userSelection]}
            else
                exit $status
            fi
            
        # Shutdown
        elif [[ ${userSelection} == ${shutdownOption} ]]; then
            println "Shutting down system."
            exit 0

        # Reboot
        elif [[ ${userSelection} == ${rebootOption} ]]; then
            println "Rebooting system."
            exit 1
        else
            println "Invalid input. Please try again."
        fi
    done
fi
