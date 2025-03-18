#!/bin/bash

# mnml2 preview
# usage: ./.mnml2.sh [drive] [username] [password] [hostname] [timezone]

set -e

EFI_SIZE="512MiB"
LOCALE="en_US.UTF-8"

clear
echo "WARNING: This script will completely erase ${1}!"
echo "Make sure you have backed up all data. Press Ctrl+C now to cancel."
read -n 1 -s -r -p "Press any key to continue..."

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

echo "${LOCALE} UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

echo "${4}" > /etc/4
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
title	mnml2
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	\${KERNEL_OPTIONS}
ENTRY

useradd -m -G wheel -s /bin/bash ${2}
echo "${2}:${3}" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOF
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

arch-chroot /mnt pacman -Sy --noconfirm --needed hyprland waybar foot wofi mako ttf-jetbrains-mono-nerd terminus-font firefox eza neovim swww

CONFIG_DIR="/mnt/home/${2}/.config"
mkdir -p ${CONFIG_DIR}/{hypr,waybar,foot}

cat <<'EOF' > ${CONFIG_DIR}/hypr/hyprland.conf
general {
	gaps_in = 2
	gaps_out = 1
	border_size = 0
	col.active_border = 0xcc6666
	col.inactive_border = 0xbb5555
}

input {
	kb_layout = us
	follow_mouse = 1
}

misc {
	disable_hyprland_logo = true
	enable_swallow = true
}

decoration {
	active_opacity = 0.90
	inactive_opacity = 0.75
	fullscreen_opacity = 1.0

	blur {
		enabled = true
		size = 10
		passes = 3
		new_optimizations = on
	}
}

bind = ALT, RETURN, exec, foot
bind = ALT, d, exec, wofi --show drun
bind = ALT, q, killactive
bind = ALT, f, fullscreen
bind = ALT, w, exec, firefox
bind = ALT, Escape, exit

bind = ALT, 1, workspace, 1
bind = ALT, 2, workspace, 2
bind = ALT, 3, workspace, 3
bind = ALT, 4, workspace, 4
bind = ALT, 5, workspace, 5
bind = ALT, 6, workspace, 6
bind = ALT, 7, workspace, 7
bind = ALT, 8, workspace, 8
bind = ALT, 9, workspace, 9

exec-once = mako &
exec-once = waybar &
exec-once = swww init && swww img ~/.wallpaper.jpeg
EOF

cat <<'EOF' > ${CONFIG_DIR}/waybar/config
{
	"height": 20,
	"layer": "top",
	"position": "top",
	"modules-left": ["hyprland/workspaces"],
	"modules-center": ["hyprland/window"],
	"modules-right": ["cpu", "memory", "clock"],

	"cpu": {
		"format": "CPU {usage}%",
		"tooltip": true
	},

	"memory": {
		"format": "RAM {percentage}%",
		"tooltip": true
	},

	"clock": {
		"format": "{:%I:%M:%S %p}",
		"tooltip-format": "{:%A, %B %d, %Y}",
		"interval": 1
	}
}
EOF

cat <<'EOF' > ${CONFIG_DIR}/waybar/style.css
* {
	border: none;
	min-height: 0px;
	font-family: "JetBrains Mono Nerd Font Mono";
	font-size: 8px;
	background: #222222;
	color: #f5f5f5;
}

#waybar {
	opacity: 0.8;
}

#workspaces button {
	border-radius: 0px;
	padding: 0px;
}

#workspaces, #clock, #cpu, #memory {
	padding: 0px 4px;
	margin: 0px 2px;
}
EOF

cat <<'EOF' > ${CONFIG_DIR}/foot/foot.ini
[main]
font = JetBrains Mono Nerd Font Mono:size=8
shell = /bin/bash
word-delimiters = " /\\()\"'-.,:;<>~!@#$%^&*+=[]{}~?'"

[colors]
foreground = dcdcdc
background = 1e1e1e

regular0 = 282828
regular1 = cc241d
regular2 = 98971a
regular3 = d79921
regular4 = 458588
regular5 = b16286
regular6 = 689d6a
regular7 = a89984

bright0 = 928374
bright1 = fb4934
bright2 = b8bb26
bright3 = fabd2f
bright4 = 83a598
bright5 = d3869b
bright6 = 8ec07c
bright7 = ebdbb2

[scrollback]
lines = 10000
multiplier = 3
EOF

cat <<'EOF' >> /mnt/home/${2}/.bash_profile
if [[ "$(tty)" = "/dev/tty1" ]]; then
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

	exec Hyprland
fi
EOF

cat <<'EOF' >> /mnt/home/${2}/.bashrc
alias c="cp -r"
alias d="rm -rf"
alias g="git clone"
alias i="sudo pacman -S --needed --noconfirm"
alias l="eza -al --icons"
alias u="sudo pacman -R --noconfirm -ss"
alias v="nvim"

alias vb="nvim ~/.bashrc"
alias fb="nvim ~/.config/foot/foot.ini"
alias vh="nvim ~/.config/hypr/hyprland.conf"
alias wc="nvim ~/.config/waybar/config"
alias ws="nvim ~/.config/waybar/style.css"
EOF

curl -o /mnt/home/${2}/.wallpaper.jpeg https://images.pexels.com/photos/1183099/pexels-photo-1183099.jpeg
arch-chroot /mnt chown -R ${2}:${2} /home/${2}
unmount -R /mnt

clear
echo "Installation complete! You can now reboot into your new mnml2 system."
