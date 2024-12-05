#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf
centered_message "MNML Phase 2 - Started\n"

centered_message "[setting up graphical environment]"
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

centered_message "MNML Phase 2 - Completed! Proceeding Towards Phase 3..."
