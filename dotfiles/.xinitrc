#!/usr/bin/env bash

dunst -conf "~/.config/dunst/dunstrc" &
feh --bg-scale .wallpaper.jpg
picom -b
slstatus &

exec dwm
