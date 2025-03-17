# mnml
A Minimal Arch Setup
(inspired by [ArchTitus](https://github.com/ChrisTitusTech/ArchTitus))

![mnml](mnml.png)

## Overview
mnml is a lightweight and customizable Arch setup designed for minimalism enthusiasts. Built around the [suckless](https://suckless.org) desktop philosophy, it offers an efficient and distraction-free desktop environment.

## Installation
To get started, simply run the following from the Arch installer:
```bash
bash <(curl -L raw.githubusercontent.com/thatdhruv/mnml/master/install.sh)
```

## Getting Started
mnml uses the default dwm key bindings with the modifier (`Mod`) key being the `⌘ (Cmd) | ❖ (Super) | ⊞ (Win)` key depending on your platform. For example, you can get started by opening a terminal session, or launching programs as:
- `Mod + Shift + Return`: Launch a terminal session
- `Mod + P`: Launch dmenu (program launcher)

In addition to the default key bindings, mnml includes these additional key bindings for ease of use:
- `Mod + Shift + M`: Mute or unmute the system volume
- `Mod + Shift + P`: Shut the system down (use with caution)
- `Mod + Shift + S`: Take a screenshot (saved to the user's home directory)
- `Mod + Shift + W`: Open firefox
- `Mod + S`: Toggle the system color scheme (default is dark)

You can add your own key bindings, or modify the current key bindings by editing the sources.
