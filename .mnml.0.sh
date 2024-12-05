#!/usr/bin/env bash

source $MNMLDIR/.mnml.conf
centered_message "MNML Phase 0 - Started\n"

iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --needed --noconfirm archlinux-keyring
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
pacman -S --needed --noconfirm reflector rsync grub

centered_message "[setting up $iso mirrors for optimal downloads]"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null

centered_message "[formatting disks]"
umount -A --recursive /mnt
sgdisk -Z ${MNMLDISK}
sgdisk -a 2048 -o ${MNMLDISK}
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${MNMLDISK}
sgdisk -n 2::+300M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${MNMLDISK}
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${MNMLDISK}
if [[ ! -d "/sys/firmware/efi" ]] ; then
	sgdisk -A 1:set:2 ${MNMLDISK}
fi
partprobe ${MNMLDISK}

centered_message "[creating filesystems]"
if [[ "${MNMLDISK}" =~ "nvme" ]] ; then
	partition2=${MNMLDISK}p2
	partition3=${MNMLDISK}p3
else
	partition2=${MNMLDISK}2
	partition3=${MNMLDISK}3
fi
mkfs.vfat -F32 -n "EFIBOOT" ${partition2}
mkfs.ext4 -F -L ROOT ${partition3}
mount -t ext4 ${partition3} /mnt
mkdir -p /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/
if ! grep -qs '/mnt' /proc/mounts ; then
	clear
	centered_message "[disk is not mounted!]\n"
	centered_message "[rebooting in 3s...]" && sleep 1
	centered_message "[rebooting in 2s...]" && sleep 1
	centered_message "[rebooting in 1s...]" && sleep 1
	reboot now
fi

centered_message "[installing the base system]"
pacstrap /mnt base base-devel linux linux-firmware archlinux-keyring sudo vim --needed --noconfirm
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${MNMLDIR} /mnt/root/MNML
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
genfstab -L /mnt >> /mnt/etc/fstab

centered_message "[installing bootloader]"
if [[ ! -d "/sys/firmware/efi" ]] ; then
	grub-install --boot-directory=/mnt/boot ${MNMLDISK}
else
	pacstrap /mnt efibootmgr --needed --noconfirm
fi

centered_message "[checking if a swap file will be needed...]"
MNMLMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ MNMLMEM -lt 8000000 ]] ; then
	mkdir -p /mnt/opt/swap
	dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
	chmod 600 /mnt/opt/swap/swapfile
	chown root /mnt/opt/swap/swapfile
	mkswap /mnt/opt/swap/swapfile
	swapon /mnt/opt/swap/swapfile
	echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab
fi

centered_message "MNML Phase 0 - Completed! Proceeding Towards Phase 1..."
