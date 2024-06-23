#!/usr/bin/env fish

set line_power_path (upower -e | grep line_power)
set cable_plugged (upower -i $line_power_path | grep -A2 'line-power' | grep online | awk '{ print $2 }')

if test "$cable_plugged" = "yes"
	swaylock -f -c 000000 -i ~/Wallpapers/swaylock.png
else
	set dialog_path (realpath ~/.assets/lock-dialog.xml)
	set choice (gtkdialog --file="$dialog_path")

	if string match -q -- "*lock*" $choice
		swaylock -f -c 000000 -i ~/Wallpapers/swaylock.png
	end
end

