#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf

echo -ne "
\033[0;31m[setting up network services]\033[0m
"
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
pacman -S --noconfirm networkmanager grub git
systemctl enable --now NetworkManager

nc=$(grep -c ^processor /proc/cpuinfo)
echo -ne "
\033[0;31m[setting up makeflags and compression settings for "$nc" cores]\033[0m
"
MNMLTMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $MNMLTMEM -gt 8000000 ]] ; then
	sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
	sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z -T $nc -)/g" /etc/makepkg.conf
fi

echo -ne "
\033[0;31m[setting up locale]\033[0m
"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone ${MNMLTIME}
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-keymap us
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
ln -s /usr/share/zoneinfo/${MNMLTIME} /etc/localtime
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

echo -ne "
\033[0;31m[installing packages]\033[0m
"
while read line
do
	echo "[installing ${line}]"
	sudo pacman -S --needed --noconfirm ${line}
done < $MNMLDIR/.mnml.pkgs

echo -ne "
\033[0;31m[installing microcode]\033[0m
"
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type} ; then
	echo "[installing intel microcode]"
	pacman -S --needed --noconfirm intel-ucode
	proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type} ; then
	echo "[installing amd microcode]"
	pacman -S --needed --noconfirm amd-ucode
	proc_ucode=amd-ucode.img
fi

echo -ne "
\033[0;31m[installing graphics drivers]\033[0m
"
gpu=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu} ; then
	pacman -S --needed --noconfirm nvidia
	nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD" ; then
	pacman -S --needed --noconfirm xf86-video-amdgpu
elif grep -E "Intel Graphics Controller" <<< ${gpu} ; then
	pacman -S --needed --noconfirm xf86-video-intel
elif grep -E "Intel Corporation UHD" <<< ${gpu} ; then
	pacman -S --needed --noconfirm xf86-video-intel
fi

echo -ne "
\033[0;31m[setting up user]\033[0m
"
if [ $(whoami) = "root" ] ; then
	useradd -m -G audio,input,video,wheel -s /bin/bash $MNMLUSER
	echo "[successfully added user $MNMLUSER]"
	echo "$MNMLUSER:$MNMLPASS" | chpasswd
	echo "[successfully set password for $MNMLUSER]"
	echo "$MNMLUSER ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
	cp -R $HOME/mnml /home/$MNMLUSER/
	chown -R $MNMLUSER: /home/$MNMLUSER/mnml
	echo "[mnml copied to home directory]"
	echo $MNMLHOST > /etc/hostname
else
	echo "You already seem to be a user. Proceeding with phase 2..."
fi

echo -ne "
\033[0;31m[ready for phase 2]\033[0m
"
