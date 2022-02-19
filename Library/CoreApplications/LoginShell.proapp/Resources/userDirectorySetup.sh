#!/bin/bash

@import File/new
@import Hermes/system

userID="$1"
userDir="$2"

# User directory structure
directories="
${userDir}/Library/LoginScript
${userDir}/Library/Preferences
${userDir}/Library/ApplicationData
${userDir}/Library/Logs
${userDir}/Library/Cache
${userDir}/Documents
${userDir}/Applications
"

# Files
files="
${userDir}/Library/history
"

# Create the directories
for directory in $directories; do
    s_log "Creating directory: $directory"
    File.createDirectory "$directory"
done

# Create the files
for file in $files; do
    s_log "Creating file: $file"
    File.overwrite "$file"
done