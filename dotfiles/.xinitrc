#!/usr/bin/env bash

dunst -conf ~/.config/dunst/dark &
feh --bg-scale .wallpaper.dark.jpg
picom -b
slstatus &

exec dwm
