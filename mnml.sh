#!/usr/bin/env bash

setfont ter-v18b

if [ "$TERM" = "linux" ]; then
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
fi

set -a
MNMLDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set +a

bash $MNMLDIR/.mnml.start.sh
source $MNMLDIR/.mnml.conf
bash $MNMLDIR/.mnml.0.sh
arch-chroot /mnt $HOME/mnml/.mnml.1.sh
arch-chroot /mnt /usr/bin/runuser -u $MNMLUSER -- /home/$MNMLUSER/mnml/.mnml.2.sh
arch-chroot /mnt $HOME/mnml/.mnml.3.sh

centered_message "MNML Phase 3 - Completed! Please Eject Install Media and Reboot..."
