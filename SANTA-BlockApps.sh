#!/bin/bash

# List of applications to block
APPS=("FaceTime" "Messages" )

# Log file path
LOG_FILE="/var/log/block_app.log"

# Function to write to the log
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Log the start of the script
log_message "Script started."

# Check if santactl is installed
log_message "Checking if santactl is installed..."
if ! command -v /usr/local/bin/santactl &> /dev/null; then
    log_message "Error: Santa is not installed!"
    exit 1
fi
log_message "Santa is installed."

# Log the start of the blocking process
log_message "Starting application blocking process."

# Loop through each application in the list
for app in "${APPS[@]}"; do
    APP_PATH="/System/Applications/$app.app"

    # Log the check for the app's existence
    log_message "Checking if the application $app exists at $APP_PATH..."

    # Check if the application exists
    if [ ! -d "$APP_PATH" ]; then
        log_message "Error: Application $app does not exist at $APP_PATH"
        continue
    fi
    log_message "Application $app exists."

    # Log the action of blocking the app
    log_message "Blocking the application $app..."
    
    # Block the app using santactl
    if sudo /usr/local/bin/santactl rule --signingid --block --path "$APP_PATH"; then
        log_message "Application $app successfully blocked."
    else
        log_message "Error blocking application $app."
    fi
done

# Log the completion of the script
log_message "Operation completed."

