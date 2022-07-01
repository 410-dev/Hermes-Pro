@import Foundation/out
@import File
@import Hermes

# Check if directory exists
if [[ ! $(File.isDirectory "${DATA}") ]]; then
    s_log "[DataDriveAdapter] Data VDrive not exists!"
    s_log "[DataDriveAdapter] Prompting..."

    # Prompt user to create a new data drive
    while true; do
        input "Create a new data drive? (y/n): " createNewDataDrive
        if [[ ${createNewDataDrive} == "y" ]]; then
            break
        elif [[ ${createNewDataDrive} == "n" ]]; then
            exit 1
        else
            println "Invalid input. Please try again."
        fi
    done

    s_log "[DataDriveAdapter] Creating: cache"
    File.createDirectory "${CACHE}"
    s_log "[DataDriveAdapter] Created: cache"

    s_log "[DataDriveAdapter] Creating: logs"
    File.createDirectory "${LOGS}"
    s_log "[DataDriveAdapter] Created: logs"

    s_log "[DataDriveAdapter] Creating: data"
    File.createDirectory "${DATA}/Applications"
    s_log "[DataDriveAdapter] Created: data"
    
    println "Data drive created."
fi

