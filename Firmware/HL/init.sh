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
verbose "[*] Finished loading primary frameworks."

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
verbose "[*] Finished loading secondary frameworks."

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
verbose "[*] Finished loading tertiary frameworks."

export FinalLoadTarget="$(cat "$(dirname "$0")/FinalLoadTarget")"
for i in $FinalLoadTarget; do
    verbose "[*] Loading final target bundle: $i"
    bundle_start "$SYSTEM/CoreExecutives/$i"
    export exitcode=$?
    if [[ "$exitcode" == "111" ]]; then
        verbose "[-] There was an error while loading bundle at $i"
    elif [[ "$exitcode" == "0" ]] && [[ ! -z "$(echo "$i" | grep "UserShell")" ]]; then
        verbose "[*] Shell has exited."
        exit $exitcode
    elif [[ "$exitcode" == "0" ]]; then
        verbose "[*] Task finished."
    else
        verbose "[-] Not proper exit code!"
    fi
done
