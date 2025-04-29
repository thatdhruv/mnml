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
KERNEL_OPTIONS="root=UUID=\${ROOT_UUID} rw"

cat <<ENTRY >/boot/loader/entries/arch.conf
title	Boot Into teletype
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	\${KERNEL_OPTIONS}
ENTRY

useradd -m -G wheel -s /bin/bash ${2}
echo "${2}:${3}" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
EOF
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

arch-chroot /mnt pacman -Sy --noconfirm --needed git vim terminus-font tmux

cat <<VIMRC >> /mnt/home/${2}/.vimrc
set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

set number
set norelativenumber

set autoindent
set smartindent
set backspace=indent,eol,start
set scrolloff=3
set noerrorbells
set showcmd
set showmode
set ruler
set laststatus=2
set statusline=%F%m%r%h%w\\ [POS=%l,%c][%p%%]

set incsearch
set hlsearch

set background=dark

set nobackup
set nowritebackup
set noswapfile

set encoding=utf-8
set fileencoding=utf-8
VIMRC

cat <<TMUXCONF >> /mnt/home/${2}/.tmux.conf
set-option -g status-position top

set-option -g repeat-time 300

set-option -g base-index 1
setw -g pane-base-index 1

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind | split-window h
bind - split-window -v

set -g status on
set -g status-interval 1
set -g status-justify centre

set -g status-bg black
set -g status-fg white

set -g status-left-length 40
set -g status-left "#[fg=green]#S"
set -g status-right-length 90
set -g status-right "#[fg=blue]%a #[fg=cyan]%b %d %Y #[fg=yellow]%H:%M:%S"

setw -g window-status-format "#I:#W"
setw -g window-status-current-format "#[fg=cyan,bold]#I:#W"

set-option -g bell-action none
TMUXCONF

cat <<BASH_PROFILE >> /mnt/home/${2}/.bash_profile

if [[ "\$(tty)" = "/dev/tty1" ]]; then
 	setfont ter-v16b

	echo -en "\e]P0282828"
	echo -en "\e]P1cc241d"
	echo -en "\e]P298971a"
	echo -en "\e]P3d79921"
	echo -en "\e]P4458588"
	echo -en "\e]P5b16286"
	echo -en "\e]P6689d6a"
	echo -en "\e]P7a89984"
	echo -en "\e]P8928374"
	echo -en "\e]P9fb4934"
	echo -en "\e]PAb8bb26"
	echo -en "\e]PBfabd2f"
	echo -en "\e]PC83a598"
	echo -en "\e]PDd3869b"
	echo -en "\e]PE8ec07c"
	echo -en "\e]PFebdbb2"
	clear

	tmux new-session -A -s "\$(tty)"
fi
BASH_PROFILE

cat <<BASHRC >> /mnt/home/${2}/.bashrc

### start of user-defined aliases ###
alias b="source ~/.bashrc"
alias c="cp -r"
alias d="rm -rf"
alias g="git clone"
alias i="sudo pacman -S --needed --noconfirm"
alias l="ls -al --color=auto"
alias m="mkdir -p"
alias u="sudo pacman -R --noconfirm -ss"
alias v="vim"

alias vb="vim ~/.bashrc"
alias vp="vim ~/.bash_profile"
### end of user-defined aliases ###

PS1='\e[0;31m\u\e[m@\e[0;34m\h \e[0;32m\w \e[0;35m\\\$ \e[m'
BASHRC

umount -R /mnt

clear
echo "Installation complete! You can now reboot into your new teletype system."
