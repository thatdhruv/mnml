#!/usr/bin/env bash

pacman -Sy --needed --noconfirm git
git clone https://github.com/thatdhruv/mnml
cd mnml
chmod +x *.sh
./mnml.sh
