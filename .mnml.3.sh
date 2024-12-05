#!/usr/bin/env bash

source $HOME/mnml/.mnml.conf
centered_message "MNML Phase 3 - Started\n"

if [[ -d "/sys/firmware/efi" ]] ; then
	grub-install --efi-directory=/boot ${MNMLDISK}
fi

centered_message "[generating grub configuration]"
grub-mkconfig -o /boot/grub/grub.cfg

centered_message "[enabling services]"
systemctl enable NetworkManager.service

centered_message "[cleaning up]"
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i "s/^$MNMLUSER ALL=(ALL:ALL) NOPASSWD: ALL/# $MNMLUSER ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
rm -rf $HOME/mnml /home/$MNMLUSER/mnml
cd $pwd
