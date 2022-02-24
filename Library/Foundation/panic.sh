#!/bin/bash

@import Foundation/out
println "${RED}!!!!!!!!!!!!!!! -- SYSTEM PANIC -- !!!!!!!!!!!!!!!"
if [[ "$1" == "halt" ]]; then
    while [[ true ]]; do
        sleep 100
    done
fi
exit 0
