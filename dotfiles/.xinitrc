#!/usr/bin/env bash

picom -b
feh --bg-scale .wallpaper.jpg
slstatus &

exec dwm
