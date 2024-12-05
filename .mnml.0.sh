#!/usr/bin/env bash

source $MNMLDIR/.mnml.conf
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --needed --noconfirm archlinux-keyring
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
pacman -S --needed --noconfirm reflector rsync grub

echo -ne "
\033[0;31m[setting up $iso mirrors for optimal downloads]\033[0m
"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null

echo -ne "
\033[0;31m[formatting disks]\033[0m
"
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


echo -ne "
\033[0;31m[creating filesystems]\033[0m
"
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
	echo -ne "\033[0;31m[disk is not mounted!]\033[0m"
	echo
	echo -ne "\033[0;31m[rebooting in 3s...]\033[0m" && sleep 1
	echo -ne "\033[0;31m[rebooting in 2s...]\033[0m" && sleep 1
	echo -ne "\033[0;31m[rebooting in 1s...]\033[0m" && sleep 1
	reboot now
fi

echo -ne "
\033[0;31m[installing the base system]\033[0m
"
pacstrap /mnt base base-devel linux linux-firmware archlinux-keyring sudo vim --needed --noconfirm
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${MNMLDIR} /mnt/root/MNML
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
genfstab -L /mnt >> /mnt/etc/fstab

echo -ne "
\033[0;31m[installing bootloader]\033[0m
"
if [[ ! -d "/sys/firmware/efi" ]] ; then
	grub-install --boot-directory=/mnt/boot ${MNMLDISK}
else
	pacstrap /mnt efibootmgr --needed --noconfirm
fi

echo -ne "
\033[0;31m[checking if a swap file will be needed...]\033[0m
"
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

echo -ne "
\033[0;31m[ready for phase 1]\033[0m
"
