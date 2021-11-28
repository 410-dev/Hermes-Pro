#!/bin/bash

verbose "[*] Making symbolic link..."
if [[ -e "$LIBRARY/Developer/eBash/main" ]]; then
    verbose "[*] Link already exists, removing."
    rm -rf "$LIBRARY/Developer/eBash/main"
fi
ln -s "$LIBRARY/Developer/eBash/ebash1.0alpha.ebashkit" "$LIBRARY/Developer/eBash/main"



# Always do this task at last.