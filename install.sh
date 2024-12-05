#!/usr/bin/env bash

pacman -Sy --needed --noconfirm git
git clone https://github.com/thatdhruv/mnml
cd mnml
./mnml.sh
