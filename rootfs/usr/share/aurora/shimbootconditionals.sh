#!/bin/bash

if cat /mnt/shimroot/sbin/bootstrap.sh | grep "│ Shimboot OS Selector" --quiet; then
	echo -e "${COLOR_YELLOW_B}Shimboot (unpatched) detected. Please use shimboot-priism.${COLOR_RESET}"
	umount /mnt/shimroot
	losetup -D
	export skipshimboot=1
	read -p "Press enter to continue."
	clear
	return
elif cat /mnt/shimroot/sbin/bootstrap.sh | grep "│ Priishimboot OS Selector" --quiet; then
	echo -e "${COLOR_GREEN}Priishimboot detected.${COLOR_RESET}"
	if ! cgpt find -l "shimboot_rootfs:priism" > /dev/null; then
		echo -e "${COLOR_YELLOW_B}Please use Priishimbooter before booting!${COLOR_RESET}"
    	umount /mnt/shimroot
	   	losetup -D
		export skipshimboot=1
		read -p "Press enter to continue."
		clear
		return
	fi
fi
if cat $shimroot/usr/share/aurora/aurora.sh | grep "https://github.com/EtherealWorkshop/Aurora" --quiet; then
	echo -e "${COLOR_YELLOW_B}I will try my absolute hardest to make the inception work as much as you want${COLOR_RESET}"
	read -p "Press enter to continue."
	clear
	return
fi