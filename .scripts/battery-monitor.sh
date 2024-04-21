#!/usr/bin/env bash
#
# Set the battery level threshold
BATTERY_THRESHOLD=98

# Function to check battery level
check_battery() {
    BATTERY_PATH=$(upower -e | grep battery)
    LINE_POWER_PATH=$(upower -e | grep line_power)
    BATTERY_PERCENTAGE=$(upower -i $BATTERY_PATH | grep 'percentage:' | awk '{ print $2 }' | sed 's/%//')

    # Check if battery level is below the threshold
    if [ "$BATTERY_PERCENTAGE" -lt "$BATTERY_THRESHOLD" ]; then
        # Send an urgent notification
        notify-send "Battery Low" "Your battery level is below $BATTERY_THRESHOLD%. Please plug in your charger." -u critical
    fi
}

# Main loop
while true; do
    # Check battery level
    check_battery

    # Sleep for 60 seconds
    sleep 60
done

