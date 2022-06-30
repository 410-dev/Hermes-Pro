#!/bin/bash
@import Foundation/out

println "${BLUE}${OS_NAME} ${OS_CODENAME}"
println "Version: ${OS_VERSION}"
println "Build: ${OS_BUILD}"
println "Command Set: ${OS_BIN_SET}"

if [[ "${OS_TESTVERSIONBOOL}" == "true" ]]; then
    println ""
    println "This is a test version."
    println "This version is not intended for general use."
    println "Test Version: ${OS_TESTVERSION}"
fi
