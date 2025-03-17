#!/bin/sh

DUNSTRC="$HOME/.config/dunst/dunstrc"

if grep -q "background = \"#222222\"" "$DUNSTRC"; then
  cat > "$DUNSTRC" << EOF
[global]
background = "#e5e5ea"
foreground = "#222222"
font = Terminess Nerd Font Mono 10

[frame]
border_color = "#007aff"

[body]
background = "#e5e5ea"
foreground = "#222222"

[notification]
frame_color = "#007aff"
EOF
else
  cat > "$DUNSTRC" << EOF
[global]
background = "#222222"
foreground = "#ffffff"
font = Terminess Nerd Font Mono 10

[frame]
border_color = "#cc6666"

[body]
background = "#222222"
foreground = "#ffffff"

[notification]
frame_color = "#cc6666"
EOF
fi
