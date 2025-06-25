#!/bin/bash

setsid -c test
trap '' INT
trap '' SIGINT
trap '' EXIT

clear
export aroot="/usr/share/aurora"
export releaseBuild=1
export shimroot="$aroot/shimroot"
export recoroot="$aroot/recoroot"
export COLOR_RESET="\033[0m"
export COLOR_BLACK_B="\033[1;30m"
export COLOR_RED_B="\033[1;31m"
export COLOR_GEEN="\033[0;32m"
export COLOR_GEEN_B="\033[1;32m"
export COLOR_YELLOW="\033[0;33m"
export COLOR_YELLOW_B="\033[1;33m"
export COLOR_BLUE_B="\033[1;34m"
export COLOR_MAGENTA_B="\033[1;35m"
export COLOR_PINK_B="\x1b[1;38;2;235;170;238m"
export COLOR_CYAN_B="\033[1;36m"
export PS1='$(cat /etc/hostname):\w\$ '

funText() {
	splashText=(
        "The lower tape fade meme is still massive." 
        " It most like existed in the first place." 
        "              HACKED BY GEEN" 
        "    \"how do i type a backslash\" -simon" 
        "  MURDER DRONES SEASON 2 IS REAL I SWEAR"
        "   Well-made Quality Assured Durability" 
        "        "purr :3 mrrow" - Synaptic" 
        "          who else but quagmire?\n         he's quagmire, quagmire,\n        you never really know what\n            he's gonna do next\n          he's quagmire, quagmire,\n       giggitygiggitygiggitygiggity\n             let's have [...]"
        "             rhymes with grug"
        "             rhymes with grug"
        "               i'm kxtz cuh"
        "        now with free thigh highs!"
        "                    :3"
        " cr50 hammer? i think you meant \"no PoC\"."
        "            public nuisance???\n        is that a hannah reference"

        )
  	selectedSplashText=${splashText[$RANDOM % ${#splashText[@]}]} # it just really rhymes with grug what can i say
	echo -e " "
   	echo -e "$selectedSplashText"
}

splash() {
    local width=42
	local verstring=${VERSION["STRING"]}
	local build=${VERSION["BUILDDATE"]}
	local version_pad=$(( (width - ${#verstring}) / 2 ))
    local build_pad=$(( (width - ${#build}) / 2 ))
    echo -e "$COLOR_BLUE_B"
    cat <<EOF
╒════════════════════════════════════════╕
│ .    . .    '    +   *       o    .    │
│+  '.                    '   .-.     +  │
│          +      .    +   .   ) )     ''│
│                   '  .      '-´  *.    │
│     .    \      .     .  .  +          │
│         .-o-'       '    .o        o   │
│  *        \      *            +'       │
│                '       '               │
│        .*       .       o   o      .   │
│              o     . *.                │
│ 'o*           .        .'    .         │
│              ┏┓   '. O           *     │
│     .*       ┣┫┓┏┏┓┏┓┏┓┏┓  .    \      │
│     o        ┛┗┗┻┛ ┗┛┛ ┗┻     +        │
╘════════════════════════════════════════╛
EOF
    echo -e "$(printf "%*s%s" $version_pad "" "$verstring")"
    echo -e "$(printf "%*s%s" $build_pad "" "$build")"
    echo -e "${COLOR_RESET}"
    echo -e "https://github.com/EtherealWorkshop/Aurora"
    funText
    echo -e " "
}

if [[ $releaseBuild -eq 1 ]]; then
	trap '' INT
fi

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

splash
aurora_files=dev=$(cgpt find -l Aurora $dev || cgpt find -t rootfs $dev | head -n 1)
aurora_disk=$(echo /dev/$(lsblk -ndo pkname ${aurora_files} || echo -e "${COLOR_YELLOW_B}Warning${COLOR_RESET}: Failed to enumerate disk! Resizing will most likely fail."))


source /etc/lsb-release 2&> /dev/null

mount $aurora_files $aroot || fail "Failed to mount Aurora partition!"

if [ ! -z "$(ls -A $aroot/.IMAGES_NOT_YET_RESIZED 2> /dev/null)" ]; then # this janky shit is the only way it works. idk why.
	echo -e "${COLOR_YELLOW}Aurora needs to resize your images partition!${COLOR_RESET}"
	
	read -p "Press enter to continue."
	
	echo -e "${COLOR_GEEN}Info: Growing Aurora partition${COLOR_RESET}"
	
	umount $aurora_files
	
	growpart $aurora_disk 5 # growpart. why. why did you have to be different.
	# those who know why it had to be different
	e2fsck -f $aurora_files
	
	echo -e "${COLOR_GEEN}Info: Resizing filesystem (This operation may take a while, do not panic if it looks stuck!)${COLOR_RESET}"
	
	resize2fs -p $aurora_files || fail "Failed to resize filesystem on ${aurora_files}!"
	
	echo -e "${COLOR_GEEN}Done. Remounting partition...${COLOR_RESET}"
	
	mount $aurora_files $aroot/
	rm -rf $aroot/.IMAGES_NOT_YET_RESIZED
	sync
fi

chmod 777 $aroot/*
recochoose=($aroot/recovery/*)
shimchoose=($aroot/shims/*)
selpayload=($aroot/payloads/*.sh)
STATEFUL_MNT=/stateful
source /irs/shimscripts/packages.sh
source /irs/shimscripts/irs.sh
mkdir /mnt/cros && mount /dev/mmcblk