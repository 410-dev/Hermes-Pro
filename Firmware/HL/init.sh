#!/bin/bash

cd "$SYSTEM/CoreFrameworks"
# Read all directories using for loop
for i in *.primaryframework; do
    cd "$SYSTEM/CoreFrameworks"
    verbose "[*] Loading primary framework: $i"
    if [ -d "$i" ]; then
        if [ -f "$i/main.hmdat" ]; then
            source "$i/meta.hmdat"
            if [[ "$BUNDLE_EXECUTIVE" == "HeliumNative" ]]; then
                source "$i/main.hmdat" "$SYSTEM/CoreFrameworks/$i"
            else
                verbose "[-] Primary framework $i is not loaded because it is not a compatible architecture."
            fi
        else
            verbose "[-] Primary framework $i is not loaded because it is not in a readable format."
        fi
    else
        verbose "[-] Primary framework $i is not loaded because it is not in a readable format."
    fi
done

for i in *.secondaryframework; do
    cd "$SYSTEM/CoreFrameworks"
    verbose "[*] Loading secondary framework: $i"
    if [ -d "$i" ]; then
        if [ -f "$i/main.hmdat" ]; then
            source "$i/meta.hmdat"
            if [[ "$BUNDLE_EXECUTIVE" == "HeliumNative" ]]; then
                source "$i/main.hmdat" "$SYSTEM/CoreFrameworks/$i"
            else
                verbose "[-] Secondary framework $i is not loaded because it is not a compatible architecture."
            fi
        else
            verbose "[-] Secondary framework $i is not loaded because it is not in a readable format."
        fi
    else
        verbose "[-] Secondary framework $i is not loaded because it is not in a readable format."
    fi
done

for i in *.tertiaryframework; do
    cd "$SYSTEM/CoreFrameworks"
    verbose "[*] Loading tertiary framework: $i"
    if [ -d "$i" ]; then
        if [ -f "$i/main.hmdat" ]; then
            source "$i/meta.hmdat"
            if [[ "$BUNDLE_EXECUTIVE" == "HeliumNative" ]]; then
                source "$i/main.hmdat" "$SYSTEM/CoreFrameworks/$i"
            else
                verbose "[-] Tertiary framework $i is not loaded because it is not a compatible architecture."
            fi
        else
            verbose "[-] Tertiary framework $i is not loaded because it is not in a readable format."
        fi
    else
        verbose "[-] Tertiary framework $i is not loaded because it is not in a readable format."
    fi
done

source "$(dirname "$0")/FinalLoadTarget"
bundle_start "$FinalLoadTarget"
export exitcode=$?
if [[ "$exitcode" == "111" ]]; then
    verbose "[-] There was an error while loading "
else
    verbose "[*] Shell has exited."
    exit $exitcode
fi