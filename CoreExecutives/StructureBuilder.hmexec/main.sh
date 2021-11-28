#!/bin/bash

source "$1/schema"
verbose "[*] Building missing core directories..."
# Scan through dirList
for dir in $SUBDIR_LIBRARY; do
    if [[ ! -d "$LIBRARY/$dir" ]]; then
        verbose "[*] Creating directory: $LIBRARY/$dir"
        mkdir -p "$LIBRARY/$dir"
    fi
done
for dir in $SUBDIR_DATA; do
    if [[ ! -d "$DATA/$dir" ]]; then
        verbose "[*] Creating directory: $DATA/$dir"
        mkdir -p "$DATA/$dir"
    fi
done

unset SUBDIR_DATA
unset SUBDIR_LIBRARY
unset dir

if [[ -f "$1/subbuilder/preinstall.sh" ]]; then
    verbose "[*] Running preinstall script..."
    "$1/subbuilder/preinstall.sh"
fi
if [[ -f "$1/subbuilder/postinstall.sh" ]]; then
    verbose "[*] Running postinstall script..."
    "$1/subbuilder/postinstall.sh"
fi

bundle_start "$SYSTEM/CoreExecutives/UserShell.hmexec"
