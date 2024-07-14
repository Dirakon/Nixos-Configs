#!/usr/bin/env bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

# This controls (in seconds) when to switch to the next image
INTERVAL=300

while true; do
	~/.scripts/hyprpaper-set-random-wallpaper.fish
	sleep "$INTERVAL"
done
