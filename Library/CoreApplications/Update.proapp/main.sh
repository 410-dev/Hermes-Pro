#!/bin/bash

@import Network/get
@import Hermes/preferences

# Update channel codes:
# stable
# beta
# dev


# Get update channel from preference
UPDATECHANNEL=$(Hermes.pref "System.UpdateUtility.Channel")

# If there is beta configuration, then use beta channel
if [[ $(Hermes.pref "System.UpdateUtility.UseDevelBeta") == "true" ]]; then
    UPDATECHANNEL="dev"
fi

# Get update channel
if [[ ${UPDATECHANNEL} == "stable" ]]; then
    UPDATEURL="https://hermes.io/update/stable/update.json"
elif [[ ${UPDATECHANNEL} == "beta" ]]; then
    UPDATEURL="https://hermes.io/update/beta/update.json"
elif [[ ${UPDATECHANNEL} == "dev" ]]; then
    UPDATEURL="https://hermes.io/update/dev/update.json"
else
    UPDATEURL="https://hermes.io/update/stable/update.json"
fi
