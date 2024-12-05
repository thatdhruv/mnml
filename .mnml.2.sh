#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf

echo -ne "
\033[0;31m[setting up graphical environment]\033[0m
"
cd $MNMLDIR/dmenu
make
sudo make install
cd $MNMLDIR/dwm
make
sudo make install
cd $MNMLDIR/slstatus
make
sudo make install
cd $MNMLDIR/st
make
sudo make install
cp -r $MNMLDIR/dotfiles/. $HOME/.
chmod +x $HOME/.scripts/*.sh

echo -ne "
\033[0;31m[ready for phase 3]\033[0m
"
