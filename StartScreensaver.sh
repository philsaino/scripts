#!/bin/bash

# Function to check if a YouTube video is playing and not paused
check_youtube_playing() {
    # Use AppleScript to check if a YouTube video is playing and not paused in Safari
    osascript -e 'tell application "System Events"
        set youtube_playing to false
        if exists process "Safari" then
            tell application "Safari" to set youtube_playing to exists (tabs of windows whose URL contains "youtube.com/watch")
            if youtube_playing then
                tell application "Safari" to set youtube_paused to (do JavaScript "document.querySelector(\"video\").paused" in document 1)
                if youtube_paused then
                    return false
                else
                    return true
                end if
            else
                return false
            end if
        else
            return false
        end if
    end tell'
}

# Function to get mouse inactivity time
get_idle_time() {
    echo $(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}')
}

# Maximum inactivity time in seconds (10 minutes)
MAX_IDLE_TIME=5

# Infinite loop
while true; do
    # Check if a YouTube video is playing and not paused
    youtube_playing_result=$(check_youtube_playing)
    # If youtube_playing_result is empty, set it to "false"
    if [ -z "$youtube_playing_result" ]; then
        youtube_playing_result=false
    fi
    echo "YouTube playing: $youtube_playing_result"
    if [ "$youtube_playing_result" = false ]; then
        # Get mouse inactivity time
        IDLE_TIME=$(get_idle_time)
        echo "Idle time: $IDLE_TIME"
        # Check if the mouse is inactive for more than 20 minutes
        if (( $(echo "$IDLE_TIME > $MAX_IDLE_TIME" | bc -l) )); then
            # Open the screensaver system preferences
            open /System/Library/CoreServices/ScreenSaverEngine.app
        fi
    fi
    
    # Wait for a while before checking again
    sleep 10 # Check state every 60 seconds
done
