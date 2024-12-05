#!/usr/bin/env bash

picom -b
feh --bg-scale .wallpaper.dark.jpg
slstatus &

exec dwm
