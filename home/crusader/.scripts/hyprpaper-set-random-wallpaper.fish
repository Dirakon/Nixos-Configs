#!/usr/bin/env fish


set img (find "/home/dirakon/Wallpapers/Final/" -type f | shuf -n 1)
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$img"
# TODO: other monitors?
hyprctl hyprpaper wallpaper "eDP-1,$img"
