#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="[\u@\h \W]\$ "

### start of user-defined aliases ###
alias c="cp -r"
alias d="rm -rf"
alias g="git clone"
alias i="sudo pacman -S --needed --noconfirm"
alias l="eza -al --icons"
alias n="neofetch"
alias r="ranger"
alias u="sudo pacman -R --noconfirm"
alias v="vim"
### end of user-defined alises ###
