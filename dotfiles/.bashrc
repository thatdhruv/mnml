#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="[\u@\h \W]\$ "

### start of user-defined aliases ###
alias b="source ~/.bashrc"
alias c="cp -r"
alias d="rm -rf"
alias g="git clone"
alias i="sudo pacman -S --needed --noconfirm"
alias l="eza -al --icons"
alias m="mkdir -p"
alias n="neofetch"
alias r="ranger"
alias u="sudo pacman -R --noconfirm -ss"
alias v="vim --servername VIM"

alias vb="vim --servername VIM ~/.bashrc"
alias vp="vim --servername VIM ~/.bash_profile"
alias vv="vim --servername VIM ~/.vimrc"
### end of user-defined alises ###

mc() { mkdir -p "$1" && cd "$1"; }
