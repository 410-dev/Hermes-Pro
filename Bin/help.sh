#!/bin/bash

@import Foundation/out
@import Foundation/string
@import File/list
@import File/check
@import File/read


if [[ "$(String.isNull "$1")" ]]; then
    println "$(File.list "$SYSTEM/Manuals")"
else
    if [[ "$(File.isFile "$SYSTEM/Manuals/$1")" ]]; then
        println "$(File.readString "$SYSTEM/Manuals/$1")"
    else
        println "${RED}Help: manual not found for: $1"
    fi
fi
