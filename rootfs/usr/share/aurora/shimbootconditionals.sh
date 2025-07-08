#!/bin/bash
if [ -f "/mnt/shimroot/bin/kvs" ]; then
	export skipshimboot=1
    echo -e "You are attempting to boot a KVS shim. This is ${COLOR_RED_B}NOT${COLOR_RESET} recommended."
    echo "Aurora has the latest release of KVS built into the shim, and it has the capability of exiting back to the Aurora menu."
    echo "Only use the KVS shim if you have modified it"
    read -p "Use the built-in KVS? (Y/n)" whichkvs
    case $whichkvs in
        n|N) /mnt/shimroot/bin/kvs
        *) /usr/bin/kvs
    esac
    return
fi
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