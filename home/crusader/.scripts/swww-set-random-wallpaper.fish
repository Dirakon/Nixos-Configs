#!/usr/bin/env fish


set img (find "/home/dirakon/Wallpapers/Final/" -type f | shuf -n 1)
swww img "$img"
