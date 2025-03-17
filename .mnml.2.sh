#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf
clear
centered_message "MNML Phase 2 - Started\n"

centered_message "[setting up graphical environment]"
cd $HOME/mnml/dmenu
make
sudo make install
cd $HOME/mnml/dwm
make
sudo make install
cd $HOME/mnml/slstatus
make
sudo make install
cd $HOME/mnml/st
make
sudo make install
cp -r $HOME/mnml/dotfiles/. $HOME/.
chmod +x $HOME/.scripts/*.sh

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

centered_message "MNML Phase 2 - Completed! Proceeding Towards Phase 3..."
