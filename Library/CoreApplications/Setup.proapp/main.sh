#!/bin/bash

# Do initial setup for the machine / system

@import Hermes/preferences
@import Foundation/out
@import File/new


println "Welcome to Hermes!"
println "This script will help you setup your machine."
# println "Please answer the following questions:"

println "Please wait until the setup is complete. It will be done in just a seconds."
println " "
println "You will be asked to enter your username and password."
println "It is just a process of making a new user account."
println "When the setup is complete, you may use your computer."
println " "

# Create users directory
File.createDirectory "${DATA}/Users"

# Set user count to 0
Hermes.pref "System.UserCounts" "0"

# Set update channel to stable channel
Hermes.pref "System.UpdateUtility.Channel" "stable"

# Setup is complete
Hermes.pref "System.setupComplete" "true"