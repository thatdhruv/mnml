#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf

if [[ -d "/sys/firmware/efi" ]] ; then
	grub-install --efi-directory=/boot ${MNMLDISK}
fi

echo -ne "
\033[0;31m[generating grub configuration]\033[0m
"
grub-mkconfig -o /boot/grub/grub.cfg

echo -ne "
\033[0;31m[enabling services]\033[0m
"
systemctl enable NetworkManager.service

echo -ne "
\033[0;31m[cleaning up]\033[0m
"
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i "s/^$MNMLUSER ALL=(ALL:ALL) NOPASSWD: ALL/# $MNMLUSER ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
rm -rf $HOME/mnml /home/$MNMLUSER/mnml
cd $pwd
