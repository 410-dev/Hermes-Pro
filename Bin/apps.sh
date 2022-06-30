#!/bin/bash
@import File/list
@import File/check
@import Foundation/out
@import Foundation/string

println "System Applications"
println "-------------------"
files="$(File.list "${SYSTEM}/Applications")"
for file in $files; do
    if [[ $(File.isDirectory "${SYSTEM}/Applications/$file") ]]; then
        println "$(String.replace "$file" ".proapp" " ")"
    fi
done

println ""
println "Global Applications"
println "-------------------"
files="$(File.list "${DATA}/Applications")"
for file in $files; do
    if [[ $(File.isDirectory "${DATA}/Applications/$file") ]]; then
        println "$(String.replace "$file" ".proapp" " ")"
    fi
done

println ""
println "User Applications"
println "-----------------"
files="$(File.list "${userDir}/Applications")"
for file in $files; do
    if [[ $(File.isDirectory "${userDir}/Applications/$file") ]]; then
        println "$(String.replace "$file" ".proapp" " ")"
    fi
done
