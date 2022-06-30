#!/bin/bash

# Exit code:
# 0: Success
# 1: Error
# 2: Warning

# This script is loaded when preparing the system for an update.
# It is downloaded before the OTA update is downloaded.
# It is run when:
#    - Optimizing OTA to the machine (Before installing the ota)
#    - Updating the system (While installing the ota)
#    - Rebooting the system (After installing the ota, starting up for the first time after update)
# 
# It receives the following parameters:
#    - $1: The type of script to run (--prepare, --update, or --reboot)


echo "There's nothing to do here."
exit 0
