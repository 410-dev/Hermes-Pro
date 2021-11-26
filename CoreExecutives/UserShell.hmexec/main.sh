#!/bin/bash

# infinite loop
while true; do
    # read user input
    print "Enter your command: "
    export command=$(singleline_input)
    # execute command
    if [[ "$command" == "exit" ]]; then
        break
    fi
done

exit 0