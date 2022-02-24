#!/bin/bash

# Do initial setup for the machine / system

@import Hermes/preferences
@import Foundation/out
@import Foundation/in
@import File/new


println "Welcome to Hermes!"
println "This script will help you setup your machine."

println "Please wait until the setup is complete."
println " "
println "It is just a process of making a new user account."
println "When the setup is complete, you may use your computer."
println " "

# Create users directory
File.createDirectory "${DATA}/Users"

# Set user count to 0
Hermes.pref "System.UserCounts" "0"

# Set update channel to stable channel
Hermes.pref "System.UpdateUtility.Channel" "main"

# Configure the machine name
input "Please enter the name of your machine: " machineName
Hermes.pref "System.MachineName" "${machineName}"


# Setup is complete
Hermes.pref "System.setupComplete" "true"