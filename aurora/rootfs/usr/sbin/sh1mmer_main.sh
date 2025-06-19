#!/bin/bash

clear

fail() {
	printf "Failure: Aborting..."
	reco="exit"
}
export -f fail

get_largest_cros_blockdev() {
	local largest size dev_name tmp_size remo
	size=0
	for blockdev in /sys/block/*; do
		dev_name="${blockdev##*/}"
		echo -e "$dev_name" | grep -q '^\(loop\|ram\)' && continue
		tmp_size=$(cat "$blockdev"/size)
		remo=$(cat "$blockdev"/removable)
		if [ "$tmp_size" -gt "$size" ] && [ "${remo:-0}" -eq 0 ]; then
			case "$(sfdisk -d "/dev/$dev_name" 2>/dev/null)" in
				*'name="STATE"'*'name="KERN-A"'*'name="ROOT-A"'*)
					largest="/dev/$dev_name"
					size="$tmp_size"
					;;
			esac
		fi
	done
	echo -e "$largest"
}
export -f get_largest_cros_blockdev
splash 1
mkdir /irs
mkdir /mnt/{newroot,shimroot,recoroot}
# Credits to xmb9 for a good portion of what's below this comment
aurora_images="/dev/disk/by-label/AURORA_IMAGES"
aurora_disk=$(echo /dev/$(lsblk -ndo pkname ${aurora_images} || echo -e "${COLOR_YELLOW_B}Warning${COLOR_RESET}: Failed to enumerate disk! Resizing will most likely fail."))
mount --mkdir $aurora_images /usr/share/aurora/mount/images/ || fail "Failed to mount IRS_FILES partition!"
if [ ! -z "$(ls -A /irs/.IMAGES_NOT_YET_RESIZED 2> /dev/null)" ]; then
	echo -e "${COLOR_YELLOW}Aurora needs to resize your images partition!${COLOR_RESET}"
	echo -e "${COLOR_GREEN}Info: Growing AURORA_IMAGES partition${COLOR_RESET}"
	umount $aurora_images
	growpart $aurora_disk 5
    e2fsck -f $aurora_images
	echo -e "${COLOR_GREEN}Info: Resizing filesystem (This operation may take a while, do not panic if it looks stuck!)${COLOR_RESET}"
	resize2fs -p $aurora_images || fail "Failed to resize filesystem on ${aurora_images}!"
	echo -e "${COLOR_GREEN}Done. Remounting partition...${COLOR_RESET}"
	mount $aurora_images /irs
	rm -rf /irs/.IMAGES_NOT_YET_RESIZED
	sync
fi
chmod 777 /usr/share/aurora/mount/images/*
source /usr/share/aurora/mount/images/sihmscripts/packages.sh
source /usr/share/aurora/mount/images/sihmscripts/aurora.sh