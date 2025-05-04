#!/bin/bash

# teletype preview
# usage: ./teletype.sh [drive] [username] [password] [hostname] [timezone]

set -e

EFI_SIZE="256MiB"
LOCALE="en_US.UTF-8"

clear

sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf

parted -s ${1} mklabel gpt

parted -s ${1} mkpart ESP fat32 1MiB ${EFI_SIZE}
parted -s ${1} set 1 boot on

parted -s ${1} mkpart primary ext4 ${EFI_SIZE} 100%

EFI_PARTITION="${1}1"
ROOT_PARTITION="${1}2"

mkfs.fat -F32 ${EFI_PARTITION}
mkfs.ext4 -F ${ROOT_PARTITION}

mount ${ROOT_PARTITION} /mnt
mkdir -p /mnt/boot
mount ${EFI_PARTITION} /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware systemd sudo

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/${5} /etc/localtime
hwclock --systohc
timedatectl set-ntp true

echo "${LOCALE} UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

echo "${4}" > /etc/hostname
cat <<HOSTS >/etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	${4}.localdomain ${4}
HOSTS

echo -en "[Match]\nName=enp*\n[Network]\nDHCP=yes" > /etc/systemd/network/20-wired.network
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

bootctl --path=/boot install
cat <<BOOTCFG >/boot/loader/loader.conf
default arch
timeout 3
editor 0
BOOTCFG

ROOT_UUID=\$(blkid -s UUID -o value ${ROOT_PARTITION})
KERNEL_OPTIONS="root=UUID=\${ROOT_UUID} rw quiet video=1920x1080 loglevel=3"

cat <<ENTRY >/boot/loader/entries/arch.conf
title	Boot Into teletype
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	\${KERNEL_OPTIONS}
ENTRY

useradd -m -G wheel,video -s /bin/bash ${2}
echo "${2}:${3}" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
EOF
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

mkdir -p /mnt/home/${2}/.config/{emacs,fbterm,nvim,tmux}
curl -o /mnt/home/${2}/.wallpaper.jpg "https://raw.githubusercontent.com/thatdhruv/mnml/master/.wallpaper.jpg"

cat <<INITEL >> /mnt/home/${2}/.config/emacs/init.el
(menu-bar-mode -1)

(setq inhibit-startup-message t)
(global-display-line-numbers-mode t)
(global-font-lock-mode t)
(save-place-mode 1)
(global-auto-revert-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(load-theme 'wombat t)

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default major-mode 'text-mode)
(setq initial-major-mode 'text-mode)
(setq initial-scratch-message nil)
(prefer-coding-system 'utf-8)
INITEL

cat <<FBTERMRC >> /mnt/home/${2}/.config/fbterm/fbtermrc
font-names=JetBrainMono Nerd Font Mono,JetBrainsMono NFM:style=Bold
font-size=18

color-0=000000
color-1=e78284
color-2=a6d189
color-3=ffffbb
color-4=899bdf
color-5=ca9ee6
color-6=8bbec2
color-7=cccccc
color-8=555555
color-9=ef9f9f
color-10=b5e8b0
color-11=ffff00
color-12=a6b9ef
color-13=d0a8ef
color-14=99d1db
color-15=ffffff

color-foreground=7
color-background=0

history-lines=0

cursor-shape=1
cursor-interval=300

word-chars=._-

screen-rotate=0
FBTERMRC

cat <<INITLUA >> /mnt/home/${2}/.config/nvim/init.lua
vim.o.autoindent = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.tabstop = 2
INITLUA

cat <<TMUXCONF >> /mnt/home/${2}/.config/tmux/tmux.conf
unbind C-b

set-option -g prefix C-j
bind C-j send-prefix

set-option -g status-position top

set-option -g repeat-time 300

set-option -g base-index 1
setw -g pane-base-index 1

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind | split-window -h
bind - split-window -v

bind r source-file ~/.tmux.conf

set -g status on
set -g status-interval 1
set -g status-justify centre

set -g status-bg white
set -g status-fg black

set -g status-left-length 40
set -g status-left "#S"
set -g status-right-length 90
set -g status-right "%a %b %d %Y %H:%M:%S"

setw -g window-status-format "#[bold]#I:#W"
setw -g window-status-current-format "#I:#W"
TMUXCONF

cat <<BASH_PROFILE >> /mnt/home/${2}/.bash_profile

if [[ "\$(tty)" = "/dev/tty1" ]]; then
	echo -ne "\e[?25l"
	fbv -cuiker ".wallpaper.jpg" << EOF
	q
EOF
	shift
	export FBTERM_BACKGROUND_IMAGE=1
	exec fbterm -- tmux new-session -A -s "\$(tty)"
fi
BASH_PROFILE

cat <<BASHRC >> /mnt/home/${2}/.bashrc

### start of user-defined aliases ###
alias b="source ~/.bashrc"
alias c="cp -r"
alias e="emacs"
alias d="rm -rf"
alias g="git clone"
alias i="sudo pacman -S --needed --noconfirm"
alias l="eza -al --icons"
alias m="mkdir -p"
alias u="sudo pacman -R --noconfirm -ss"
alias v="nvim"

alias vb="nvim ~/.bashrc"
alias ve="nvim ~/.config/emacs/init.el"
alias vf="nvim ~/.config/fbterm/fbtermrc"
alias vp="nvim ~/.bash_profile"
alias vt="nvim ~/.config/tmux/tmux.conf"
alias vv="nvim ~/.config/nvim/init.lua"

alias eb="emacs ~/.bashrc"
alias ee="emacs ~/.config/emacs/init.el"
alias ef="emacs ~/.config/fbterm/fbtermrc"
alias ep="emacs ~/.bash_profile"
alias et="emacs ~/.config/tmux/tmux.conf"
alias ev="emacs ~/.config/nvim/init.lua"
### end of user-defined aliases ###

mc() { mkdir -p "\$1" && cd "\$1"; }

PS1='\e[0;31m\u\e[m@\e[0;34m\h \e[0;32m\w \e[0;35m\\\$ \e[m'
BASHRC

cat <<CHROOT >> /mnt/home/${2}/chroot.sh
sudo pacman -Sy --noconfirm --needed clang emacs-nox eza git imagemagick neovim nodejs npm rust tmux ttf-jetbrains-mono-nerd unzip wget

sudo chown -R ${2}:${2} /home/${2}
cd /home/${2}
git clone https://aur.archlinux.org/fbterm
cd fbterm
makepkg -si --noconfirm --needed
cd /home/${2}
sudo setcap cap_sys_tty_config+ep /usr/bin/fbterm
rm -rf fbterm

git clone https://aur.archlinux.org/fbv
cd fbv
makepkg -si --noconfirm --needed
cd /home/${2}
rm -rf fbv

sudo sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sudo sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
CHROOT

chmod +x /mnt/home/${2}/chroot.sh
arch-chroot /mnt /usr/bin/runuser -u ${2} -- /home/${2}/chroot.sh
rm -rf /mnt/home/${2}/chroot.sh
umount -R /mnt

clear
echo "Installation complete! You can now reboot into your new teletype system."
