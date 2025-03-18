#!/usr/bin/env bash

picom -b
feh --bg-scale .wallpaper.dark.jpg
slstatus &
dunst -conf "~/.config/dunst/dark" &

exec dwm
