#!/bin/bash

# Copyright 2025 Ethereal Workshop. All rights reserved.
# Use of this source code is governed by the BSD 3-Clause license
# that can be found in the LICENSE.md file.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# BY USING THIS SOFTWARE, YOU ALSO AGREE THAT ETHEREAL WORKSHOP HAS
# THE LEGAL RIGHTS TO YOUR FIRSTBORN CHILD, AND MAY STEAL ANY OF
# YOUR CHILDREN AND THROW THEM ON A ROAD DURING ONCOMING TRAFFIC.
# DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

stty intr ''

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#################
## DEFINITIONS ##
#################

export aroot="/usr/share/aurora"
recochoose=($aroot/images/recovery/*)
shimchoose=($aroot/images/shims/*)
payloadchoose=($aroot/payloads/*)
export releaseBuild=1
export shimroot="/shimroot"
export recoroot="/recoroot"
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
export PS1='\[\033[1;34m\]$(cat /etc/hostname):\[\e[0m\]\[\033[1;32m\]\w/\[\e[0m\] # '

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
mkdir -p $aroot/images/shims
mkdir -p $aroot/images/recovery
mkdir -p $aroot/images/gurt
declare -A VERSION

VERSION["BRANCH"]="dev-alpine"
VERSION["NUMBER"]="3.0"
VERSION["BUILDDATE"]="[2025-06-20]"
VERSION["RELNAME"]="Rhymes with Grug"
VERSION["STRING"]="v${VERSION["NUMBER"]} ${VERSION["BRANCH"]} - \"${VERSION["RELNAME"]}\""

####################
## BASE FUNCTIONS ##
####################

echo_c() {
    local text="$1"
    local color_variable="$2"
    local color="${!color_variable}"
    echo -e "${color}${text}${COLOR_RESET}"
}
echo_center() {
    local text="$1"
    local width=$(tput cols)
    local length=${#text}
    local spacing=$(( (width - length) / 2 ))
    spacing=$((spacing < 0 ? 0 : spacing))
    printf "%*s%s\n" "$spacing" "" "$text"
}

errormessage() {
    if [ -n "$errormsg" ]; then 
        echo -e "${COLOR_RED_B}Error: ${errormsg}${COLOR_RESET}"
    fi
}

menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local count=${#options[@]}
    tput civis
    echo "$prompt"
    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            tput smul
            echo " > ${options[i]}"
            tput rmul
        else
            echo "   ${options[i]}"
        fi
    done
    while true; do
        tput cuu $count
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                tput smul
                echo " > ${options[i]}"
                tput rmul
            else
                echo "   ${options[i]}"
            fi
        done

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
        fi
        case $key in
            '[A') ((selected--)) ;;
            '[B') ((selected++)) ;;
            '') break ;;
        esac

        ((selected < 0)) && selected=$((count - 1))
        ((selected >= count)) && selected=0
    done
    tput cnorm
    return $selected
}

fail() {
	printf "Aurora panic: ${COLOR_RED_B}%b${COLOR_RESET}\n" "$*" >&2 || :
	printf "panic: We are hanging here..."
	sync
	losetup -D
	hang
}

hang() {
	tput civis
	stty -echo
	sleep 1h
	echo "You really still haven't turned off your device?"
	sleep 1d
	echo "I give up. Bye."
	sleep 5
	reboot -f
}

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

credits() {
    echo -e "${COLOR_MAGENTA_B}Credits"
    echo -e "${COLOR_PINK_B}Sophia${COLOR_RESET}: Lead developer of Aurora, Got Wifi"
    echo -e "${COLOR_GEEN_B}xmb9${COLOR_RESET}: Made Priism, Giving Aurora the ability to Boot Shims & Use Reco Images"
    echo -e "${COLOR_YELLOW_B}Synaptic${COLOR_RESET}: Emotional Support"
    echo -e "${COLOR_CYAN_B}Simon${COLOR_RESET}: Brainstormed how to do wifi, helped with dhcpcd"
    echo -e "${COLOR_BLUE_B}kraeb${COLOR_RESET}: QoL improvements and initial idea"
    echo -e "${COLOR_RED_B}Mariah Carey${COLOR_RESET}: Bugtesting wifi"
    echo -e "${COLOR_MAGNETA_B}AC3${COLOR_RESET}: Literally nothing"
    echo -e "${COLOR_GEEN_B}Rainestorme${COLOR_RESET}: Murkmod's version finder"
    echo -e " "
    read -p "Press Enter to return to the main menu..."
	clear
	splash
}



funText() {
	splashText=(
        "The lower tape fade meme is still massive."
        "It most likely existed in the first place." 
        "              HACKED BY GEEN              " 
        "    \"how do i type a backslash\" -simon  " 
        "  MURDER DRONES SEASON 2 IS REAL I SWEAR  "
        "          JCJENSON in SPAAAAAAC3          "
        "   Well-made Quality Assured Durability   " 
        "        \"purr :3 mrrow\" - Synaptic      " 
        "          who else but quagmire?\n         he's quagmire, quagmire,\n        you never really know what\n            he's gonna do next\n          he's quagmire, quagmire,\n       giggitygiggitygiggitygiggity\n             let's have [...]"
        "             rhymes with grug             "
        "             rhymes with grug             "
        "        now with free thigh highs!        "
        "                    :3                    "
        " cr50 hammer? i think you meant \"no PoC\"."
        "            public nuisance???\n        is that a hannah reference"
        "  can you overdose on pepperjack cheese?  "
        "make me staff lil bro i'm overqualified..."
        "                 :cheese;                 "
        "       toilet command best command!       "
        "          Sign in to Letterloop:\n                Hi friend,\nClick here to sign in with this magic link\n             -Letterloop Team"
        "            Also try Terraria!            "
        "       Terraria: Also try Minecraft       "
        "        HOW MANY HOLES IN A POLO??        "
        "             It's rewind time             "
        "     Ain't no party like a Putt Party     "
        "             Maxington hole 3             "
        "             what's a nugget?             "
        "  I'm gonna install a door on your face.  "
        "         Anne Frank in a Furnace.         "
        "           Use protection, Kids           "
        "  Can Uzi use absolute solver on my dih?  "
        "        \"hi crazy ant\" - crazy ant      "
        "              \"\"Soap\"\" Manor          "
        "   I'm gonna shove a cravat up your ass   "
        "       You barely sentient toaster.       "
        "           beautiful sophie art           "
        "             Synaptic Network             "
        "        he could be in this very room!\n             he could be you!\n             he could be me!!"
        "   Nothing built can last forever -ivor   "
        "           Your footjob is weak           "
        "      idk why age matters - shrey719      "
        "                 gurt: yo                 "
        " I am the Lorax and I speak for the trees "
        "Vaporeon is that a EndlessVortex reference"
        "              CHICKEN JOCKEY              "
        "               stellaword12               "
        "             PLEASE INSERT DI             "
        "the higher glue appear trend is now large."
        "    one cannot simply walk into mordor\n- some dumbass who didn't walk into mordor"
        "     i don't want a lot for christmas\n      there is just one thing i need"
        ) #              cen-><-ter" 

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
    errormessage
    echo -e " "
}

#############
## STARTUP ##
#############
clear
tput civis
echo -e "$COLOR_BLUE_B"
cat <<EOF | while IFS= read -r line; do echo_center "$line"; done
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
echo -e "${COLOR_RESET}"

echo_center "Starting udevd..."
/sbin/udevd --daemon || :
udevadm trigger || :
udevadm settle || :
echo_center "Done."
tput cnorm
if [ -e /usr/share/aurora/.UNRESIZED ]; then
    echo -e "${COLOR_GEEN_B}"
    echo_center "Resizing..."
    echo -e "${COLOR_RESET}"
    bash /usr/share/aurora/.UNRESIZED && rm -f /usr/share/aurora/.UNRESIZED
    echo_center "Done."
fi

##################
## MURKMOD SHIT ##
##################

lsbval() {
  local key="$1"
  local lsbfile="${2:-/etc/lsb-release}"

  if ! echo "${key}" | grep -Eq '^[a-zA-Z0-9_]+$'; then
    return 1
  fi

  sed -E -n -e \
    "/^[[:space:]]*${key}[[:space:]]*=/{
      s:^[^=]+=[[:space:]]*::
      s:[[:space:]]+$::
      p
    }" "${lsbfile}"
}

versions() {
    clear
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD)
    local board_name=${release_board%%-*}
	export board_name
    echo "What version of ChromeOS do you want to download?"
	options_install=(
	    "Latest Version"
	    "Custom Version"
	)

	menu "Select an option (use ↑ ↓ arrows, Enter to select):" "${options_install[@]}"
	install_choice=$?

	case "$install_choice" in
	    0) VERSION="latest" ;;
	    1) read -p "Enter version: " VERSION ;;
        *) echo "Invalid choice, exiting." && exit ;;
	esac
    echo "Fetching recovery image..."
    if [ $VERSION == "latest" ]; then
        export builds=$(curl -ks https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
        export hwid=$(jq "(.builds.$board_name[] | keys)[0]" <<<"$builds")
        export hwid=${hwid:1:-1}
        export milestones=$(jq ".builds.$board_name[].$hwid.pushRecoveries | keys | .[]" <<<"$builds")
        export VERSION=$(echo "$milestones" | tail -n 1 | tr -d '"')
        echo "Latest version is $VERSION"
    fi
    export url="https://raw.githubusercontent.com/rainestorme/chrome100-json/main/boards/$board_name.json"
    export json=$(curl -ks "$url")
    chrome_versions=$(echo "$json" | jq -r '.pageProps.images[].chrome')
    echo "Found $(echo "$chrome_versions" | wc -l) versions of ChromeOS for your board on Chrome100."
    echo "Searching for a match..."
    MATCH_FOUND=0
    for cros_version in $chrome_versions; do
        platform=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .platform')
        channel=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .channel')
        mp_token=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .mp_token')
        mp_key=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .mp_key')
        last_modified=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .last_modified')
        if [[ $cros_version == $VERSION* ]]; then
            echo "Found a $VERSION match on platform $platform from $last_modified."
            MATCH_FOUND=1
            FINAL_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_${platform}_${board_name}_recovery_${channel}_${mp_token}-v${mp_key}.bin.zip"
            break
        fi
    done
    if [ $MATCH_FOUND -eq 0 ]; then
        echo "No match found on Chrome100. Falling back to ChromiumDash."
        export builds=$(curl -ks https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
        export hwid=$(jq "(.builds.$board_name[] | keys)[0]" <<<"$builds")
        export hwid=${hwid:1:-1}
        milestones=$(jq ".builds.$board_name[].$hwid.pushRecoveries | keys | .[]" <<<"$builds")
        echo "Searching for a match..."
        for milestone in $milestones; do
            milestone=$(echo "$milestone" | tr -d '"')
            if [[ $milestone == $VERSION* ]]; then
                MATCH_FOUND=1
                FINAL_URL=$(jq -r ".builds.$board_name[].$hwid.pushRecoveries[\"$milestone\"]" <<<"$builds")
                echo "Found a match!"
                break
            fi
        done
    fi
    if [ $MATCH_FOUND -eq 0 ]; then
        echo "No recovery image found for your board and target version. Exiting."
        exit
    fi
	export VERSION
}

#########################
## IMPORTANT FUNCTIONS ##
#########################

detect_aurora_in_shimboot_function() {
	echo "dD0oIkhlYXJzYXkhIiAiSSByZWZ1c2UuIiAiSSBzaGFsbCBkbyBubyBzdWNoIHRoaW5nISIgIkxpa2UuLi4gd2h5Pz8/IiAiSSBjZXJ0YWlubHkgd2lsbCBub3QhIiAiQXJlIHlvdSBqdXN0IGhlcmUgdG8gZGlsbHlkYWRkbGU/IiAiWW91IHJlYWxseSBoYXZlIG5vdGhpbmcgYmV0dGVyIHRvIGRvLCBkb24ndCB5b3U/IikKcz0ke3RbJFJBTkRPTSAlICR7I3RbQF19XX0KZWNobyAtZSAiICIKZWNobyAtZSAiJHMi" | base64 -d | bash
}

export_args() {
  local arg=
  local key=
  local val=
  local acceptable_set='[A-Za-z0-9]_'
  echo "Exporting kernel arguments..."
  for arg in "$@"; do
    key=$(echo "${arg%%=*}" | busybox tr 'a-z' 'A-Z' | \
                   busybox tr -dc "$acceptable_set" '_')
    val="${arg#*=}"
    export "KERN_ARG_$key"="$val"
    echo -n " KERN_ARG_$key=$val,"
  done
  echo ""
}

export_args $(cat /proc/cmdline | sed -e 's/"[^"]*"/DROPPED/g') 1> /dev/null

copy_lsb() {
    echo "Copying lsb..."

    local lsb_file="dev_image/etc/lsb-factory"
    local src_path="${STATEFUL_MNT}/${lsb_file}"
    local dest_path="/newroot/etc/lsb-factory"

    mkdir -p "$(dirname "${dest_path}")"

    if [ -f "${src_path}" ]; then
        echo "Found ${src_path}"
        cp "${src_path}" "${dest_path}" || fail "failed with $?"
        echo "REAL_USB_DEV=${loop}p3" >> "${dest_path}"
        echo "KERN_ARG_KERN_GUID=$(echo "${KERN_ARG_KERN_GUID}" | tr '[:lower:]' '[:upper:]')" >> "${dest_path}"
        echo "Copied lsb-factory to ${dest_path}"
    else
        echo "Missing ${src_path}!"
        return 1
    fi
}


pv_dircopy() {
	[ -d "$1" ] || return 1
	local apparent_bytes
	apparent_bytes=$(du -sb "$1" | cut -f 1)
	mkdir -p "$2"
	tar -C /shimroot -cf - . | tar -C /newroot -xf -
}

############
## IMAGES ##
############

installcros() {
	if [[ -z "$(ls -A $aroot/images/recovery)" ]]; then
		echo -e "${COLOR_YELLOW_B}You have no recovery images downloaded!\nPlease download a few images."
		echo -e "Alternatively, these are available on websites such as chrome100.dev, or cros.tech. Put them into /usr/share/aurora/images/recovery"
        read -p "Press Enter to return to the main menu..."
		return
	else
        reco_options=("${recochoose[@]}" "Exit")

        reco_actions=()
                for reco_opt in "${recochoose[@]}"; do
            reco_actions+=("reco=\$reco_opt")
        done
        reco_actions+=("reco=Exit")

        while true; do
            clear
            splash
            menu "Choose the recovery image you want to boot:" "${reco_options[@]}"
            eval "${reco_actions[$?]}"
            break
        done

	fi

	if [[ $reco == "Exit" ]]; then
        read -p "Press Enter to continue..."
		clear
		splash 1
	else
		mkdir -p $recoroot
		echo -e "Searching for ROOT-A on reco image..."
		loop=$(losetup -fP --show $reco)
		loop_root="$(cgpt find -l ROOT-A $loop | head -n 1)"
		if mount -r "${loop_root}" $recoroot ; then
			echo -e "ROOT-A found successfully and mounted."
		else
 			result=$?
			err1="Mount process failed! Exit code was ${result}.\n"
			err2="              This may be a bug! Please check your recovery image,\n"
			err3="              and if it looks fine, report it to the GitHub repo!\n"
			fail "${err1}${err2}${err3}"
		fi
		local cros_dev="$(get_largest_cros_blockdev)"
  		if [ -z "$cros_dev" ]; then
			echo -e "${COLOR_YELLOW_B}No ChromeOS drive was found on the device! Please make sure ChromeOS is installed before using Aurora. Continuing anyway...${COLOR_RESET}"
		fi
		stateful="$(cgpt find -l STATE ${loop} | head -n 1 | grep --color=never /dev/)" || fail "Failed to find stateful partition on ${loop}!"
		mount $stateful /mnt/stateful_partition || fail "Failed to mount stateful partition!"
		MOUNTS="/proc /dev /sys /tmp /run /var /mnt/stateful_partition"
		cd /mnt/recoroot/
		d=
		for d in ${MOUNTS}; do
	  		mount -n --bind "${d}" "./${d}"
	  		mount --make-slave "./${d}"
		done
		chroot ./ /usr/sbin/chromeos-install --payload_image="${loop}" --yes || fail "Failed during chroot!"
		cgpt add -i 2 $cros_dev -P 15 -T 15 -S 1 -R 1 || echo -e "${COLOR_YELLOW_B}Failed to set kernel priority! Continuing anyway.${COLOR_RESET}"
		echo -e "${COLOR_GREEN}\n"
		read -p "Recovery finished. Press any key to reboot."
		reboot
		sleep 1
		echo -e "\n${COLOR_RED_B}Reboot failed. Hanging..."
	fi
}

shimboot() {
	if [[ -z "$(ls -A $aroot/images/shims)" ]]; then
		echo -e "${COLOR_YELLOW_B}You have no shims downloaded!\nPlease download or build a few images."
		echo -e "Alternatively, these are available on websites such as mirror.akane.network or dl.fanqyxl.net. Put them into /usr/share/aurora/images/shims"
        read -p "Press Enter to return to the main menu..."
		return
	else
        shim_options=("${shimchoose[@]}" "Exit")

        shim_actions=()
                for shim_opt in "${shimchoose[@]}"; do
            shim_actions+=("shim=\$shim_opt")
        done
        shim_actions+=("return")

        while true; do
            clear
            splash
            menu "Choose the shim you want to boot:" "${shim_options[@]}"
            eval "${shim_actions[$?]}"
            break
        done

	fi

	if [[ $shim == "Exit" ]]; then
        read -p "Press Enter to continue..."
		clear
	else
		mkdir -p $shimroot
		echo -e "Searching for ROOT-A on shim..."
		loop=$(losetup -fP --show $shim)
		export loop

		loop_root="$(cgpt find -l ROOT-A $loop || cgpt find -t rootfs $loop | head -n 1)"

		if mount "${loop_root}" $shimroot; then
			echo -e "ROOT-A found successfully and mounted."
		else
			result=$?
			err1="Mount process failed! Exit code was ${result}.\n"
			err2="              This may be a bug! Please check your shim,\n"
			err3="              and if it looks fine, report it to the GitHub repo!\n"
			fail "${err1}${err2}${err3}"
		fi
		export skipshimboot=0
        source /usr/share/aurora/shimbootconditionals.sh
		if ! stateful="$(cgpt find -l STATE ${loop} | head -n 1 | grep --color=never /dev/)"; then
			echo -e "${COLOR_YELLOW_B}Finding stateful via partition label \"STATE\" failed (try 1...)${COLOR_RESET}"
			if ! stateful="$(cgpt find -l SH1MMER ${loop} | head -n 1 | grep --color=never /dev/)"; then
				echo -e "${COLOR_YELLOW_B}Finding stateful via partition label \"SH1MMER\" failed (try 2...)${COLOR_RESET}"

				for dev in "$loop"*; do
					[[ -b "$dev" ]] || continue
					parttype=$(udevadm info --query=property --name="$dev" 2>/dev/null | grep '^ID_PART_ENTRY_TYPE=' | cut -d= -f2)
					if [ "$parttype" = "0fc63daf-8483-4772-8e79-3d69d8477de4" ]; then
						stateful="$dev"
						break
					fi
				done
			fi
		fi
		if [[ -z "${stateful// }" ]]; then
			echo -e "${COLOR_RED_B}Finding stateful via partition type \"Linux data\" failed! (try 3...)${COLOR_RESET}"
			echo -e "Last resort (try 4...)"
			stateful="${loop}p1"
		fi

		if (( $skipshimboot == 0 )); then
			mkdir -p /stateful
			mkdir -p /newroot

			mount -t tmpfs tmpfs /newroot -o "size=1024M" || fail "Could not allocate 1GB of TMPFS to the newroot mountpoint."
			mount $stateful /stateful || fail "Failed to mount stateful partition!"

			copy_lsb

			echo "Copying rootfs to ram."
			pv_dircopy "$shimroot" /newroot

			echo "Moving mounts..."
			mkdir -p "/newroot/dev" "/newroot/proc" "/newroot/sys" "/newroot/tmp" "/newroot/run"
			mount -t tmpfs -o mode=1777 none /newroot/tmp
			mount -t tmpfs -o mode=0555 run /newroot/run
			mkdir -p -m 0755 /newroot/run/lock

			umount -l /dev/pts
			umount -f /dev/pts

			mounts=("/dev" "/proc" "/sys")
			for mnt in "${mounts[@]}"; do
				mount --move "$mnt" "/newroot$mnt"
				umount -l "$mnt"
			done

			echo "Done."
			echo "About to switch root. If your screen goes black and the device reboots, it may be a bug. Please make a GitHub issue if you're sure your shim isn't corrupted."
			sleep 1
			echo "Switching root!"
			clear

			mkdir -p /newroot/tmp/aurora
			pivot_root /newroot /newroot/tmp/aurora
            source /usr/share/aurora/shimbootconditionals.sh
			echo "Starting init"
            checkkvs
			exec /sbin/init || {
				echo "Failed to start init!!!"
				echo "Bailing out, you are on your own. Good luck."
				echo "This shell has PID 1. Exit = panic."
				/tmp/aurora/bin/uname -a
				exec /tmp/aurora/bin/sh
			}
		fi
	fi
}

##########
## WIFI ##
##########

if [ "$needswifi" -eq 1 ]; then
    for wifi in iwlwifi iwlmvm ccm 8021q; do
        modprobe -r "$wifi" || true
        modprobe "$wifi"
    done
    export needswifi=0
    echo_center "Connecting to wifi"
    if [ -f "/etc/wpa_supplicant.conf" ]; then
        wifidevice=$(ip link 2>/dev/null | grep -E "^[0-9]+: " | grep -oE '^[0-9]+: [^:]+' | awk '{print $2}' | grep -E '^wl' | head -n1)
        wpa_supplicant -B -i "$wifidevice" -c /etc/wpa_supplicant.conf >/dev/null 2>&1

        connected=0
        for i in $(seq 1 5); do
            if iw dev "$wifidevice" link 2>/dev/null | grep -q 'Connected'; then
                udhcpc -i "$wifidevice" >/dev/null 2>&1 && connected=1
                break
            fi
            sleep 1
        done

        if [ $connected -eq 0 ]; then
            echo_center "No nearby saved networks found; Retrying..."
        fi
    fi

fi

connect() {
    read -p "Enter your network SSID: " ssid
    read -p "Enter your network password (leave blank if open network): " psk

    conf="/etc/wpa_supplicant.conf"
    if grep -q "ssid=\"$ssid\"" "$conf" 2>/dev/null; then
        echo "Network (${ssid}) already configured."
    else
        if [ -z "$psk" ]; then
            cat >> "$conf" <<EOF

network={
    ssid="$ssid"
    key_mgmt=NONE
}
EOF
        else
            wpa_passphrase "$ssid" "$psk" >> "$conf"
        fi
    fi
    killall wpa_supplicant 2>/dev/null
    killall udhcpc 2>/dev/null
    ip link set "$wifidevice" down
    ip link set "$wifidevice" up

    wpa_supplicant -B -i "$wifidevice" -c "$conf"
    udhcpc -i "$wifidevice"
}

wifi() {
    wifidevice=$(ip link | grep -E "^[0-9]+: " | grep -oE '^[0-9]+: [^:]+' | awk '{print $2}' | grep -E '^wl' | head -n1)

    if iw dev "$wifidevice" link | grep -q 'Connected'; then
        echo "Currently connected to a network."
        read -p "Connect to a different network? (y/N): " connectornah
        case $connectornah in
            y|Y|yes|Yes) connect ;;
            *) ;;
        esac
    else
        connect
    fi
    sync
}



canwifi() {
  if curl -Is https://nebulaservices.org | head -n 1 | grep -q "HTTP/"; then # the website with the best uptime is good for this usecase
    "$@"
  else
    export errormsg="You are not connected to the internet (or Nebula's down)."
  fi
}
export -f canwifi
download() {
    	options_download=(
	    "ChromeOS recovery image"
	    "ChromeOS Shim"
	)

	menu "Select an option (use ↑ ↓ arrows, Enter to select):" "${options_download[@]}"
	download_choice=$?

	case "$download_choice" in
	    0) downloadreco ;;
	    1) downloadshim ;;
        *) export errormsg="Invalid choice, exiting." && exit ;;
	esac
}
downloadreco() {
	versions
	cd $aroot/images/recovery
    curl --progress-bar -k "$FINAL_URL" -o $VERSION.zip
	unzip $VERSION.zip
	rm $VERSION.zip
}

downloadshim() {
    export errormsg="Not yet implemented" && exit
	cd $aroot/images/shims
    curl --progress-bar -k "$FINAL_URL" -o $NAME.zip
	unzip $NAME.zip
	rm $NAME.zip
}

downloadyo() {
    cd $aroot/gurt
    bash <(curl https://gurt.etherealwork.shop)
}

updateshim() {
    apk add git github-cli
    rm -rf /usr/share/aurora/aurora.sh
    if [ -d "/root/Aurora/.git" ]; then
        git -C "/root/Aurora" pull origin alpine
    else
        [ -d "/root/Aurora" ] && rm -rf "/root/Aurora"
        gh auth status &>/dev/null || gh auth login || exit 1
        git clone --branch=alpine https://github.com/EtherealWorkshop/Aurora /root/Aurora
    fi
    if [ ! -e /usr/share/aurora/.UNRESIZED ]; then
        rm -f /root/Aurora/rootfs/usr/share/aurora/.UNRESIZED
    fi
    cp -Lar /root/Aurora/rootfs/. /
    cp -Lar /root/Aurora/$(uname -m)/. /
    sync
}

##################
## OPTIONS MENU ##
##################

payloads() {
	options_payload=("${payloadchoose[@]}" "Exit")

	menu "Choose payload to run:" "${options_payload[@]}"
	choice=$?

	payload="${options_payload[$choice]}"

	if [[ $payload == "Exit" ]]; then
	    read -p "Press Enter to continue..."
	    clear
	    splash 0
	else
	    source "$payload"
	    read -p "Press Enter to continue..."
	    clear
	    splash 0
	fi
}

menu_options=(
    "Open Terminal"
    "Install a ChromeOS recovery image"
    "Boot an RMA shim"
    "Connect to WiFi"
    "Download a ChromeOS recovery image or shim"
    "Payloads"
    "Credits"
    "Update"
    "System Info"
    "Exit and Reboot"
)

menu_actions=(
    "script -qfc 'exec bash -l || exec busybox sh -l' /dev/null"
    installcros
    shimboot
    wifi
    download
    payloads
    credits
    "canwifi updateshim"
    "clear && fastfetch && sleep 10"
    "reboot -f"
)

while true; do
    clear
    splash
    stty intr ''
    menu "Select an option (use ↑ ↓ arrows, Enter to select):" "${menu_options[@]}"
    choice=$?

    if [[ "${menu_actions[$choice]}" == *"bash -l"* ]]; then
        eval "${menu_actions[$choice]}"
    else
        (
            stty intr ''
            eval "${menu_actions[$choice]}"
        )
    fi
    export errormsg=""
    stty intr ''
    sleep 1
done
