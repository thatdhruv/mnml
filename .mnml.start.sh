#!/usr/bin/env bash

config=$MNMLDIR/.mnml.conf
if [ ! -f $config ] ; then
	touch -f $config
fi

set_option() {
	if grep -Eq "^${1}.*" $config ; then
		sed -i -e "/^${1}.*/d" $config
	fi
	echo "${1}=${2}" >> $config
}

user_info() {
	read -p "Please enter your username: " mnml_user
	set_option MNMLUSER ${mnml_user,,}
	while true ; do
		echo -ne 'Please enter your password: '
		read -s mnml_pass_1
		echo -ne '\nPlease confirm your password: '
		read -s mnml_pass_2
		if [ "$mnml_pass_1" = "$mnml_pass_2" ] ; then
			set_option MNMLPASS $mnml_pass_1
			break
		else
			echo -e '\nPasswords do not match! Please try again...\n'
		fi
	done
	echo
	read -rep 'Please enter your hostname: ' mnml_host
	set_option MNMLHOST $mnml_host
}

disk_info() {
	echo -ne 'Select the disk to install on:\n'
	lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2" - "$3}'
	echo
	read -p "Please enter full path to the disk (e.g. /dev/sda): " mnml_disk
	echo
	echo -ne "${mnml_disk} selected"
	set_option MNMLDISK ${mnml_disk}
}


timezone() {
	mnml_timezone="$(curl --fail --silent https://ipapi.co/timezone)"
	echo -ne "Your timezone seems to be '${mnml_timezone}'"
	echo
	read -p "Is this correct? (Y/n): " tz
	if [[ $tz == 'y' ]] || [[ $tz == 'Y' ]] || [[ $tz == '' ]] ; then
		echo "Timezone set to ${mnml_timezone}"
		set_option MNMLTIME $mnml_timezone
	elif [[ $tz == 'n' ]] || [[ $tz == 'N' ]] ; then
		echo
		read -p "Please enter your desired timezone (e.g. Europe/London): " new_timezone
		echo "Timezone set to ${new_timezone}"
		set_option MNMLTIME $new_timezone
	else
		echo -ne '\nInvalid choice! Please try again...'
		timezone
	fi
}

clear
user_info
clear
disk_info
clear
timezone
