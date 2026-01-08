#!/usr/bin/env bash

output=$(dualsensectl battery 2>/dev/null)

if [[ "$output" == *"No device found"* ]]; then
    echo '{"text": "", "class": "no-device", "percentage": 0}'
else
    # Parse output like "75 discharging"
    percentage=$(echo "$output" | awk '{print $1}')
    status=$(echo "$output" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
    
    if [[ -n "$percentage" && -n "$status" ]]; then
        # Text is a hack for waybar's "hide-empty-text" property, see github.com/Alexays/Waybar/issues/3341
        echo "{\"text\": \"not empty\", \"class\": \"$status\", \"percentage\": $percentage}"
    else
        echo '{"text": "", "class": "no-device", "percentage": 0}'
    fi
fi
