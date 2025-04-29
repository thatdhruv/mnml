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

arch-chroot /mnt pacman -Sy --noconfirm --needed clang git neovim nodejs npm rust terminus-font tmux unzip wget

mkdir -p /mnt/home/${2}/.config/nvim

cat <<INITLUA >> /mnt/home/${2}/.config/nvim/init.lua
vim.cmd([[packadd packer.nvim]])

require('packer').startup(function()
	use 'wbthomason/packer.nvim'

 	use 'nvim-tree/nvim-tree.lua'
	use 'nvim-lua/plenary.nvim'
    	use 'nvim-telescope/telescope.nvim'
     	use 'nvim-telescope/telescope-fzy-native.nvim'
     	use 'nvim-treesitter/nvim-treesitter'
      	use 'nvim-lualine/lualine.nvim'
  	use 'neovim/nvim-lspconfig'
   	use 'williamboman/mason.nvim'
    	use 'williamboman/mason-lspconfig.nvim'
     	use 'hrsh7th/nvim-cmp'
      	use 'hrsh7th/cmp-nvim-lsp'
       	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
 	use 'saadparwaiz1/cmp_luasnip'
  	use 'L3MON4D3/LuaSnip'
   	use 'tpope/vim-fugitive'
       	use 'kyazdani42/nvim-web-devicons'
 	use 'folke/tokyonight.nvim'
  	use 'morhetz/gruvbox'
  	use 'windwp/nvim-autopairs'
end)

require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = { 'asm_lsp', 'bashls', 'clangd', 'cssls', 'html', 'pyright', 'ts_ls' },
	automatic_installation = true
})

local lspconfig = require('lspconfig')
lspconfig.asm_lsp.setup{}
lspconfig.bashls.setup{}
lspconfig.clangd.setup{}
lspconfig.cssls.setup{}
lspconfig.html.setup{}
lspconfig.pyright.setup{}
lspconfig.ts_ls.setup{}

local cmp = require('cmp')
cmp.setup({
	sources = {
 		{ name = 'nvim_lsp' },
   		{ name = 'buffer' },
     		{ name = 'path' },
       		{ name = 'luasnip' }
	}
})

require'nvim-treesitter.configs'.setup {
	ensure_installed = { "bash", "c", "cpp", "css", "html", "javascript", "nasm", "python" },
 	hightlight = {
  		enable = true,
	},
 	indent = {
  		enable = true,
	}
 }

 require('lualine').setup({
 	options = {
  		theme = 'gruvbox',
    		section_separators = '',
      		component_separators = '|',
	},
 })

 require'nvim-tree'.setup {
 	disable_netrw = true,
  	hijack_netrw = true,
   	update_cwd = true,
    	update_focused_file = {
     		enable = true,
       		update_cwd = true,
	},
 	renderer = {
  		highlight_opened_files = "all",
    		icons = {
      			show = {
	 			git = true,
     				folder = true,
	 			file = true,
     				folder_arrow = true
	 		}
    		}
      	}
}

require("nvim-autopairs").setup({})

vim.cmd[[colorscheme gruvbox]]

vim.o.autoindent = true
vim.o.number = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
INITLUA

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
alias v="nvim"

alias vb="nvim ~/.bashrc"
alias vn="nvim ~/.config/nvim/init.lua"
alias vp="nvim ~/.bash_profile"
### end of user-defined aliases ###

PS1='\e[0;31m\u\e[m@\e[0;34m\h \e[0;32m\w \e[0;35m\\\$ \e[m'
BASHRC

arch-chroot /mnt git clone --depth 1 https://github.com/wbthomason/packer.nvim /home/${2}/.local/share/nvim/site/pack/packer/start/packer.nvim
arch-chroot /mnt chown -R ${2}:${2} /home/${2}
umount -R /mnt

clear
echo "Installation complete! You can now reboot into your new teletype system."
