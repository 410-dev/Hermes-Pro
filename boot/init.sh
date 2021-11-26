#!/bin/bash
source "$(dirname "$0")/partitions.hdp"
source "$BOOTSECT/internal_func"
source "$BOOTSECT/bootloader/bootconf"
OSSTART "${@:1}"
leaveSystem