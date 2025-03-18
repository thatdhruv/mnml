#!/usr/bin/env bash

dunst &
feh --bg-scale .wallpaper.dark.jpg
picom -b
slstatus &

exec dwm
