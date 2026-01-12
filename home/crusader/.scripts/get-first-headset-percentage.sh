#!/usr/bin/env bash


# Get the battery percentage of the first headset found
PERCENTAGE=$(jc -p upower --dump | jq -r '
    [.[] | 
     select(.detail.type == "headset") |
     select(.detail.percentage != null) |
     .detail.percentage][0] // empty')

if [ -z "$PERCENTAGE" ]; then
    echo '{"text": "", "class": "no-device", "percentage": 0}'
else
    echo "{\"text\": \"not empty\", \"class\": \"normal\", \"percentage\": $PERCENTAGE}"
fi
