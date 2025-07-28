#!/bin/bash

# Copyright 2025 Ethereal Workshop. All rights reserved.
# Use of this source code is governed by the BSD 3-Clause license
# that can be found in the LICENSE.md file.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# THE COPYRIGHT HOLDERS, SPECIFICALLY SOPHIA, ARE NOT LIABLE FOR BAD CODE
# BY USING THIS SOFTWARE, YOU ALSO AGREE THAT ETHEREAL WORKSHOP HAS
# THE LEGAL RIGHTS TO YOUR FIRSTBORN CHILD, AND MAY STEAL ANY OF
# YOUR CHILDREN AND THROW THEM ON A ROAD DURING ONCOMING TRAFFIC.
# DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

stty sane
stty erase '^H'
stty intr ''
export stty=$(stty -g)
export tty="/dev/tty"
[ -e /dev/pts/0 ] && export tty="/dev/pts/0"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#################
## DEFINITIONS ##
#################

export device=$(lsblk -pro NAME,PARTLABEL,MOUNTPOINT | grep -i "Aurora /" | awk '{print $1}' | sed 's/[0-9]//')
export aroot="/usr/share/aurora"
export releaseBuild=1
export shimroot="/shimroot"
export recoroot="/recoroot"
export COLOR_RESET="\033[0m"
export BLACK_B="\033[1;30m"
export RED_B="\033[1;31m"
export GEEN="\033[0;32m"
export GEEN_B="\033[1;32m"
export YELLOW="\033[0;33m"
export YELLOW_B="\033[1;33m"
export BLUE_B="\033[1;34m"
export MAGENTA_B="\033[1;35m"
export PINK_B="\x1b[1;38;2;235;170;238m"
export CYAN_B="\033[1;36m"
export PS1='\e[1;34m\]\u@\h \e[1;33m\]$(date +"%H:%M %b %d")\e[1;32m\] \w/\[\e[0m\] '
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
mkdir -p $aroot/images/shims
mkdir -p $aroot/build
mkdir -p $aroot/images/recovery
mkdir -p $aroot/images/gurt
declare -A VERSION

VERSION["BRANCH"]="dev-alpine"
VERSION["NUMBER"]="3.0"
VERSION["BUILDDATE"]="[2025-07-16]"
VERSION["RELNAME"]="Rhymes with Grug"
VERSION["STRING"]="v${VERSION["NUMBER"]} ${VERSION["BRANCH"]} - \"${VERSION["RELNAME"]}\""

####################
## BASE FUNCTIONS ##
####################
# haha 69

funText() {
	splashText=(
        "The lower tape fade meme is still massive."
        "It most likely existed in the first place." 
        "HACKED BY GEEN" 
        "\"how do i type a backslash\" -simon" 
        "MURDER DRONES SEASON 2 IS REAL I SWEAR"
        "JCJENSON in SPAAAAAAC3"
        "Well-made Quality Assured Durability" 
        "\"purr :3 mrrow\" - Synaptic" 
        "who else but quagmire?\nhe's quagmire, quagmire,\nyou never really know what\nhe's gonna do next\nhe's quagmire, quagmire,\ngiggitygiggitygiggitygiggity\nlet's have [...]"
        "rhymes with grug"
        "rhymes with grug"
        "now with free thigh highs!"
        ":3"
        "cr50 hammer? i think you meant \"no PoC\"."
        "public nuisance???\nis that a hannah reference"
        "can you overdose on pepperjack cheese?"
        "make me staff lil bro i'm overqualified..."
        ":cheese;"
        "toilet command best command!"
        "Sign in to Letterloop:\nHi friend,\nClick here to sign in with this magic link\n-Letterloop Team"
        "Also try Terraria!"
        "Terraria: Also try Minecraft"
        "HOW MANY HOLES IN A POLO??"
        "It's rewind time"
        "Ain't no party like a Putt Party"
        "Maxington hole 3"
        "what's a nugget?"
        "I'm gonna install a door on your face."
        "Anne Frank in a Furnace."
        "Use protection, Kids"
        "Can Uzi use absolute solver on my dih?"
        "\"hi crazy ant\" - crazy ant"
        "\"\"Soap\"\" Manor"
        "I'm gonna shove a cravat up your ass"
        "You barely sentient toaster."
        "beautiful sophie art"
        "Synaptic Network"
        "he could be in this very room!\nhe could be you!\nhe could be me!!"
        "Nothing built can last forever -ivor"
        "Your footjob is weak"
        "idk why age matters - shrey719"
        "gurt: yo"
        "I am the Lorax and I speak for the trees"
        "Vaporeon is that a EndlessVortex reference"
        "CHICKEN JOCKEY"
        "stellaword12"
        "PLEASE INSERT DI"
        "the higher glue appear trend is now large."
        "one cannot simply walk into mordor\n- some dumbass who didn't walk into mordor"
        "i don't want a lot for christmas\nthere is just one thing i need"
        "we should put particles.js in a shim"
        "vermont isn't real"
        "\"Bite Me\" - Weird Al"
        "Hi there. I'm SmallAnt1."
        "Man I sure do love InitramF5"
        "If a gay bomb was dropped - Zack D Films"
        "do not drink the tasty depression that\nsays jim beam - sophia"
        "@Synaptic bad girl\ndown\nno biting!\ngo in your crate"
        "swiss cheese yo ahhh"
        "you keep using that word\ni do not think it means what you think it means."
        "give me andrew"
        "I am not fanqyxl. -Fanqyxl"
        "it runs the demon - OlyB"
        "GOOD MANNERS\n1 Wait your turn\n2 Use polite words\n3 Listen Carefully"
        "mommy may I please have fakemod :3\n- synaptic"
        "crazy ant [..] 👍"
        "Nothing beats a Jet2 Holiday"
        "VeeGay[..]"
        "rogged"
        "${RED_B}Error: Failed to find funText.${COLOR_RESET}"
        ) #              cen-><-ter" 

  	selectedSplashText=${splashText[$RANDOM % ${#splashText[@]}]} # it just really rhymes with grug what can i say
	echo -e " "
   	echo -e "$selectedSplashText"
}


echo_c() {
    local text="$1"
    local color_variable="$2"
    local color="${!color_variable}"
    echo -e "${color}${text}${COLOR_RESET}"
}

center() {
    local width=$(tput cols)
    local offset="${1:-0}"

    while IFS= read -r line || [[ -n $line ]]; do
        local plain=$(echo -e "$line" | sed -E 's/\x1b\[[0-9;]*[mK]//g')
        local len=${#plain}
        local pad=$(( (width - len) / 2 + offset ))
        (( pad < 0 )) && pad=0
        printf "%*s%s\n" "$pad" "" "$line"
    done
}

read_center() {
    local dynamic=0
    if [[ "$1" == "-d" ]]; then
        dynamic=1
        shift
    fi

    local prompt="$1"
    local readvar="$2"
    local offset="${3:-0}"
    local width=$(tput cols)

    local plain=$(echo -e "$prompt" | sed -E 's/\x1b\[[0-9;]*[mK]//g')
    local plen=${#plain}
    local pad=$(( (width - plen) / 2 + offset ))
    (( pad < 0 )) && pad=0

    if (( ! dynamic )); then
        printf "%*s%s" "$pad" "" "$prompt"
        if [[ -n "$readvar" ]]; then
            read -r "$readvar"
        else
            read -r
        fi
    else
        printf "%*s%s" "$pad" "" "$prompt"

        local input=""
        local char=""
        local ilen=0
        local nowrap=1

        local stty=$(stty -g)
        stty -icanon -echo

        while IFS= read -rsn1 char; do
            if [[ -z $char ]]; then
                break
            elif [[ $char == $'\x7f' || $char == $'\x08' || $char == $'\b'  || $char == '^H' ]]; then
                if [[ -n $input ]]; then
                    input="${input::-1}"
                    ((ilen--))
                    tput cr
                    tput el
                    local pad=$(( (width - plen - ilen) / 2 + offset ))
                    (( pad < 0 )) && pad=0
                    printf "%*s%s%s" "$pad" "" "$prompt" "$input"
                fi
            elif [[ $char == $'\x1b' ]]; then
                read -rsn2 discard
                continue
            else
                input+="$char"
                ((ilen++))

                if (( nowrap && (plen + ilen >= width) )); then
                    nowrap=0
                    echo -n "$char"
                elif (( nowrap )); then
                    tput cr
                    tput el
                    local pad=$(( (width - plen - ilen) / 2 + offset ))
                    (( pad < 0 )) && pad=0
                    printf "%*s%s%s" "$pad" "" "$prompt" "$input"
                else
                    echo -n "$char"
                fi
            fi
        done
        echo ""
        if [[ -n "$readvar" ]]; then
            printf -v "$readvar" '%s' "$input"
        fi
        stty "$stty"
    fi
}

echo_menu() {
    local text="$1"
    while IFS= read -r line; do
        local length=${#line}
        local spacing=$(( (42 - length) / 2 ))
        spacing=$((spacing < 0 ? 0 : spacing))
        printf "%*s%s\n" "$spacing" "" "$line"
    done <<< "$text"
}

menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local count=${#options[@]}
    tput civis
    echo "$prompt" | center
    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            echo "> ${options[i]} <" | center
        else
            echo "${options[i]}" | center
        fi
    done
    while true; do
        tput cuu $count
        for i in "${!options[@]}"; do
            tput el
            if [[ $i -eq $selected ]]; then
                echo "> ${options[i]} <" | center
            else
                echo "${options[i]}" | center
            fi
        done

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.01 key_rest
            key+="$key_rest"
        fi
        case $key in
            $'\x1b[A') ((selected--)) ;;
            $'\x1b[B') ((selected++)) ;;
            '') break ;;
        esac

        ((selected < 0)) && selected=$((count - 1))
        ((selected >= count)) && selected=0
    done
    tput cnorm
    return $selected
}

fail() {
    export errormsg="$1"
	sync
    cd /
    umount /dev/loop*p* 2>/dev/null
    umount /dev/loop* 2>/dev/null
	losetup -D
    for arg in "$@"; do
        if [ "$arg" = "--fatal" ]; then
            echo_c "A fatal error occured. Please Reboot" RED_B | center
            hang
        fi
    done
    return 1
}

hang() {
	tput civis
	stty -echo
	sleep 1h
	echo "You really still haven't turned off your device?" | center
	sleep 1d
	echo "I give up. Bye" | center
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

splash() {
    if [ "$(cat /sys/devices/virtual/dmi/id/product_name)" = "Barla" ]; then
        echo -e "${RED_B}Barla wifi unsupported. Please contact @kxtzownsu on discord${COLOR_RESET}"
    else
        ssid="$(iw dev "$wifidevice" link 2>/dev/null | awk -F ': ' '/SSID/ {print $2}')"
        if [ -n "$ssid" ]; then
            echo -e "\n${GEEN_B}● $wifidevice${COLOR_RESET} $ssid" | center
        else
            echo -e "\n${RED_B}● $wifidevice${COLOR_RESET} disconnected" | center
        fi
    fi
    local width=42
	local verstring=${VERSION["STRING"]}
	local build=${VERSION["BUILDDATE"]}
	local version_pad=$(( (width - ${#verstring}) / 2 ))
    local build_pad=$(( (width - ${#build}) / 2 ))
    echo -ne "$BLUE_B"
    cat <<'EOF' | center
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
    echo -e "$verstring" | center
    echo -e "$build" | center
    kernelver=$(crossystem tpm_kernver)
    echo -e "$kernelver" | center
    echo -e "${COLOR_RESET}" | center
    echo -e "https://github.com/EtherealWorkshop/Aurora" | center
    funText | center
}

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
    echo ""
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD 2>/dev/null)
    export board_name=${release_board%%-*}
    echo "What ChromeOS version do you want to download?" | center
	options_install=(
	    "Latest Version"
	    "Custom Version"
	)

	menu "Select an option (use ↑ ↓ arrows, Enter to select)" "${options_install[@]}"
	install_choice=$?

	case "$install_choice" in
	    0) chromeVersion="latest" ;;
	    1) read_center -d "Enter Version: " chromeVersion ;;
        *) fail "Invalid choice (somehow?????)" ;;
	esac
    echo "Fetching recovery image..." | center
    if [ $chromeVersion == "latest" ]; then
        builds="https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS"
        chromeVersion=$(curl -s $builds | jq -r ".builds.${board_name}.models | to_entries[0].value.servingStable.chromeVersion" | awk -F. '{print $1}')
        FINAL_URL=$(curl -s $builds | jq -r ".builds.${board_name}.models | to_entries[0].value.pushRecoveries[\"$chromeVersion\"]")
        if [ ! -n $FINAL_URL ]; then
            echo "Falling back to the most recent version found." | center
            FINAL_URL=$(curl -s $builds | jq ".builds.${board_name}.models | to_entries[0].value.pushRecoveries | to_entries | sort_by(.key | tonumber) | .[-1].value")
        fi
        export chromeVersion
        export FINAL_URL
    else
        export url="https://raw.githubusercontent.com/rainestorme/chrome100-json/main/boards/$board_name.json"
        export json=$(curl -ks "$url")
        chrome_versions=$(echo "$json" | jq -r '.pageProps.images[].chrome')
        echo "Found $(echo "$chrome_versions" | wc -l) versions of ChromeOS for your board on Chrome100." | center
        echo "Searching for a match..." | center
        MATCH_FOUND=0
        for cros_version in $chrome_versions; do
            chromeVersionPlatform=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .platform')
            channel=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .channel')
            mp_token=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .mp_token')
            mp_key=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .mp_key')
            last_modified=$(echo "$json" | jq -r --arg version "$cros_version" '.pageProps.images[] | select(.chrome == $version) | .last_modified')
            if [[ $cros_version == $chromeVersion* ]]; then
                echo "Found a $chromeVersion match on platform $chromeVersionPlatform from $last_modified." | center
                MATCH_FOUND=1
                FINAL_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_${chromeVersionPlatform}_${board_name}_recovery_${channel}_${mp_token}-v${mp_key}.bin.zip"
                export FINAL_URL
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
                if [[ $milestone == $chromeVersion* ]]; then
                    MATCH_FOUND=1
                    FINAL_URL=$(jq -r ".builds.$board_name[].$hwid.pushRecoveries[\"$milestone\"]" <<<"$builds")
                    export FINAL_URL
                    echo "Found a match!" | center
                    break
                fi
            done
        fi
        if [ $MATCH_FOUND -eq 0 ]; then
            echo "No recovery image found for your board and target version. Exiting" | center
            return
        fi
    fi
}

#########################
## IMPORTANT FUNCTIONS ##
#########################

detect_aurora_in_shimboot_function() {
	echo "dD0oIkhlYXJzYXkhIiAiSSByZWZ1c2UuIiAiSSBzaGFsbCBkbyBubyBzdWNoIHRoaW5nISIgIkxpa2UuLi4gd2h5Pz8/IiAiSSBjZXJ0YWlubHkgd2lsbCBub3QhIiAiQXJlIHlvdSBqdXN0IGhlcmUgdG8gZGlsbHlkYWRkbGU/IiAiWW91IHJlYWxseSBoYXZlIG5vdGhpbmcgYmV0dGVyIHRvIGRvLCBkb24ndCB5b3U/IikKcz0ke3RbJFJBTkRPTSAlICR7I3RbQF19XX0KZWNobyAtZSAiICIKZWNobyAtZSAiJHMi" | base64 -d | bash | center
}

export_args() {
  local arg=
  local key=
  local val=
  local acceptable_set='[A-Za-z0-9]_'
  echo "Exporting kernel argument..." | center
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
    echo "Copying lsb..." | center
    local src_path="/stateful/dev_image/etc/lsb-factory"
    local dest_path="/newroot/etc/lsb-factory"

    mkdir -p "$(dirname "${dest_path}")"

    if [ -f "${src_path}" ]; then
        echo "Found ${src_path}." | center
        cp "${src_path}" "${dest_path}" || fail "failed with $?"
        if cgpt find -l SH1MMER "${loop}" | head -n 1 | grep --color=never -q /dev/; then
            export specialshim="sh1mmer"
            echo "STATEFUL_DEV=${loop}p1" >> "${dest_path}"
        fi
        echo "REAL_USB_DEV=${loop}p3" >> "${dest_path}"
        echo "KERN_ARG_KERN_GUID=$(echo "${KERN_ARG_KERN_GUID}" | tr '[:lower:]' '[:upper:]')" >> "${dest_path}"
        echo "Copied lsb-factory to ${dest_path}" | center
    else
        fail "Missing ${src_path}!"
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
	if [[ -z "$(ls -A $aroot/images/recovery 2>/dev/null)" ]]; then
        echo -ne "${YELLOW_B}"
		echo "You have no recovery images downloaded! Please download a few images" | center
		echo "Alternatively, these are available on websites such as chrome100.dev or cros.tech. Put them into /usr/share/aurora/images/recovery" | center
        read_center "Press Enter to return to the main menu"
        echo -ne "${COLOR_RESET}"
		return
	else
        mapfile -t recochoose < <(find "$aroot/images/recovery" -type f)
        reco_options=("${recochoose[@]}" "Exit")

        reco_actions=()
        for reco_opt in "${recochoose[@]}"; do
            reco_actions+=("reco=\"${reco_opt}\"")
        done
        reco_actions+=("reco=Exit")

        while true; do
            menu "Choose the recovery image you want to boot" "${reco_options[@]}"
            eval "${reco_actions[$?]}"
            break
        done
	fi

	if [[ $reco == "Exit" ]]; then
        read_center "Press Enter to continue..."
        return
	else
		mkdir -p $recoroot
		echo -e "Searching for ROOT-A on reco image"
		loop=$(losetup -fP --show $reco)
		loop_root="$(cgpt find -l ROOT-A $loop | head -n 1)"
		if mount -r "${loop_root}" $recoroot ; then
			echo -e "ROOT-A found successfully and mounted." | center
		else
			fail "Failed to mount ROOT-A"
		fi
		local cros_dev="$(get_largest_cros_blockdev)"
  		if [ -z "$cros_dev" ]; then
			echo -e "${YELLOW_B}No ChromeOS drive was found on the device! Please make sure ChromeOS is installed before using Aurora. Continuing anyway${COLOR_RESET}" | center
		fi
		stateful="$(cgpt find -l STATE ${loop} | head -n 1 | grep --color=never /dev/)" || fail "Failed to find stateful on ${loop}!"
		mkdir /mnt/stateful_partition
		mount $stateful /mnt/stateful_partition || fail "Failed to mount stateful!"
		MOUNTS="/proc /dev /sys /tmp /run /var /mnt/stateful_partition"
		cd $recoroot
		d=
		for d in ${MOUNTS}; do
	  		mount -n --bind "${d}" "./${d}"
	  		mount --make-slave "./${d}"
		done
		chroot ./ /usr/sbin/chromeos-install --payload_image="${loop}" --yes || fail "Failed during chroot!"
  		local cros_dev="$(get_largest_cros_blockdev)"
		cgpt add -i 2 $cros_dev -P 15 -T 15 -S 1 -R 1 || echo -e "${YELLOW_B}Failed to set kernel priority! Continuing anyway${COLOR_RESET}"
		echo -e "${GEEN_B}Recovery finished. Press any key to reboot."
        read_center ""
		reboot -f
		sleep 3
        fail "Reboot failed." --fatal
	fi
}

is_ext2() {
    local rootfs="$1"
    local offset="${2-0}"

    local sb_magic_offset=$((0x438))
    local sb_value=$(dd if="$rootfs" skip=$((offset + sb_magic_offset)) \
        count=2 bs=1 2>/dev/null)
    local expected_sb_value=$(printf '\123\357')
    if [ "$sb_value" = "$expected_sb_value" ]; then
        return 0
    fi
    return 1
}

enable_rw_mount() {
    local rootfs="$1"
    local offset="${2-0}"

    if ! is_ext2 "$rootfs" $offset; then
        echo "enable_rw_mount called on non-ext2 filesystem: $rootfs $offset" 1>&2
        return 1
    fi

    local ro_compat_offset=$((0x464 + 3))
    printf '\000' |
        dd of="$rootfs" seek=$((offset + ro_compat_offset)) \
            conv=notrunc count=1 bs=1 2>/dev/null
}

shimboot() {
	if [[ -z "$(ls -A $aroot/images/shims)" ]]; then
        echo -e "${YELLOW_B}You have no shims downloaded!\nPlease download or build a few images." | center
		echo "Alternatively, these are available on websites such as mirror.akane.network or dl.fanqyxl.net. Put them into /usr/share/aurora/images/shims" | center
        read_center "Press Enter to return to the main menu..."
        echo -e "${COLOR_RESET}"
		return
	else
        mapfile -t shimchoose < <(find "$aroot/images/shims" -type f)
        shim_options=("${shimchoose[@]}" "Exit")

        shim_actions=()
        for shim_opt in "${shimchoose[@]}"; do
            shim_actions+=("shim=\"${shim_opt}\"")
        done
        shim_actions+=("return")

        while true; do
            menu "Choose the shim you want to boot:" "${shim_options[@]}"
            eval "${shim_actions[$?]}"
            break
        done
	fi

	if [[ $shim == "Exit" ]]; then
        read_center "Press Enter to continue"
		return
	else
		mkdir -p $shimroot
		echo -e "Searching for ROOT-A on shim" | center
		loop=$(losetup -Pf --show $shim)
		export loop
        if lsblk -o PARTLABEL $loop | grep "shimboot"; then
            touch /etc/shimboot
            sync
            read_center "Reboot to boot into shimboot instead of Aurora from the initramfs? (Y/n): " bootshimboot
            case $bootshimboot in
                n|N|no|No|NO) return 0 ;;
                *) losetup -D && reboot -f ;;
            esac
        fi

		loop_root="$(cgpt find -l ROOT-A "$loop" | head -n1)"
        if [ -z "$loop_root" ]; then
                loop_root="$(cgpt find -t rootfs "$loop" | head -n1)"
        fi
        if [ -z "$loop_root" ]; then
            loop_root="${loop}p3"
        fi

        enable_rw_mount ${loop_root}
		if mount "${loop_root}" $shimroot; then
			echo -e "ROOT-A found successfully and mounted." | center
		else
            fail "Failed to mount ROOT-A"
		fi
		export skipshimboot=0
		if ! stateful="$(cgpt find -l STATE ${loop} | head -n 1 | grep --color=never /dev/)"; then
			echo -e "${YELLOW_B}Finding stateful via partition label \"STATE\" failed (try 1...)${COLOR_RESET}" | center
			if ! stateful="$(cgpt find -l SH1MMER ${loop} | head -n 1 | grep --color=never /dev/)"; then
				echo -e "${YELLOW_B}Finding stateful via partition label \"SH1MMER\" failed (try 2...)${COLOR_RESET}" | center

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
			echo -e "${RED_B}Finding stateful via partition type \"Linux data\" failed (try 3...)${COLOR_RESET}" | center
			echo -e "Last resort (try 4...)" | center
			stateful="${loop}p1"
		fi
        echo "Found Stateful at $stateful" | center
		if (( $skipshimboot == 0 )); then
			mkdir -p /stateful
			mkdir -p /newroot
			mount -t tmpfs tmpfs /newroot -o "size=1024M" || fail "Failed to allocate 1GB to /newroot"
			mount $stateful /stateful || fail "Failed to mount stateful!"
            sh1mmerfile="/stateful/root/noarch/usr/sbin/sh1mmer_main.sh"
            if lsblk -o PARTLABEL $loop | grep "SH1MMER"; then
                sed -i '/^#!\/bin\/bash$/a export PATH="/bin:/sbin:/usr/bin:/usr/sbin"' $sh1mmerfile
                for i in 1 2; do sed -i '$d' $sh1mmerfile; done && echo "reboot -f" >> $sh1mmerfile && echo "Successfully patched sh1mmer_main.sh."
                cp /usr/share/patches/rootfs/init_sh1mmer.sh /stateful/bootstrap/noarch/init_sh1mmer.sh && echo "Successfully patched init_sh1mmer.sh."
                chmod +x /stateful/bootstrap/noarch/init_sh1mmer.sh
                sync
                chmod +x $sh1mmerfile
            fi

			copy_lsb
            
			echo "Copying rootfs to ram..." | center
			pv_dircopy "$shimroot" /newroot

			

            mkdir -p /newroot/dev/pts /newroot/proc /newroot/sys /newroot/tmp /newroot/run
            mount -t tmpfs -o mode=1777 none /newroot/tmp
            mount -t tmpfs -o mode=0555 run /newroot/run
            mkdir -p -m 0755 /newroot/run/lock

            for mnt in /dev /proc /sys; do
                mount --move "$mnt" "/newroot$mnt" || fail "Failed to mount $mnt"
            done

            if ! mountpoint -q /newroot/dev/pts; then
                mount -t devpts devpts /newroot/dev/pts
            fi

			echo "Done" | center
			echo "About to switch root. If your screen goes black and the device reboots, please make a GitHub issue if you're sure your shim isn't corrupted" | center
			echo "Switching root" | center
			clear

			mkdir -p /newroot/tmp/aurora
            chmod +x /usr/share/patches/rootfs/*
            if [ -n "$specialshim" ]; then
                rm -f /newroot/sbin/init
                cp /usr/share/patches/rootfs/${specialshim}init /newroot/sbin/init
            fi
            chmod +x /newroot/sbin/init
			pivot_root /newroot /newroot/tmp/aurora
			echo "Successfully switched root. Starting init..."
			exec /sbin/init || {
				echo "Failed to start init"
				echo "Bailing out, you are on your own. Good luck."
				echo "This shell has PID 1. Exit = panic"
				echo $(/tmp/aurora/bin/uname -a)
				exec /tmp/aurora/bin/sh
			}
		fi
	fi
}

kvs() {
    while true; do
        read_center -d "Enter Kernver[Max 8 characters after 0x]: 0x" kernver
        mount --bind /mount /mount
        for mnt in /dev /proc /sys; do
            mkdir -p /mount$mnt
            mount --bind "$mnt" "/mount$mnt"
        done
        vercheck=$(chroot /mount tpmc read 0x1008 1 | tr -d '\r\n[:space:]')
        if [[ "$vercheck" == *2 ]]; then
            ver=0
        elif [ "$vercheck" = "10" ]; then
            ver=1
        fi
        if [ ! -n "$ver" ]; then
            echo "$vercheck"
            break
        fi
        echo "Struct ver: $ver"
        break=1
        set -x
        chroot /mount sh -c 'tpmc write 0x1008 $(kvg 0x'"$kernver"' --ver='"$ver"')' || {
            echo "Invalid Kernver. Maximum 8 characters after 0x [eg: 0x00000001]"
            break=0
        }
        set +x
        for mnt in /dev /proc /sys; do
            umount "/mount$mnt"
        done
        if [ "$break" = "1" ]; then break; fi
    done
    sync
}

##########
## WIFI ##
##########

connect() {
    echo "Enter your network SSID" | center
    read_center -d "" ssid
    echo "Enter your network password (leave blank if none)" | center
    read_center -d "" psk
    conf="/etc/wpa_supplicant.conf"
    if grep -q "ssid=\"$ssid\"" "$conf" 2>/dev/null; then
        echo "Network (${ssid}) already configured." | center
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
    udhcpc -i "$wifidevice" || fail "Corrupted wpa_supplicant.conf has been fixed. Please reconnect"
}

wifi() {
    wifidevice=$(ip link | grep -E "^[0-9]+: " | grep -oE '^[0-9]+: [^:]+' | awk '{print $2}' | grep -E '^wl' | head -n1)

    if iw dev "$wifidevice" link 2>/dev/null | grep -q 'Connected'; then
        echo "Currently connected to a network." | center
        echo "Connect to a different network? (y/N): " | center
        read_center -d "" connectornah
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
    echo "Not connected to the internet, or Nebula Services is down."
    if curl -Is https://example.com | head -n 1 | grep -q "HTTP/"; then # nebula got ddosed like a day ago
        "$@"
    else
        fail "Not connected to the internet"
    fi
  fi
}
export -f canwifi
download() {
    	options_download=(
	    "ChromeOS recovery image"
	    "ChromeOS Shim"
	)

	menu "Select an option (use ↑ ↓ arrows, Enter to select)" "${options_download[@]}"
	download_choice=$?

	case "$download_choice" in
	    0) downloadreco ;;
	    1) downloadshim ;;
        *) fail "Invalid choice (somehow?????)" ;; 
	esac
}
downloadreco() {
	versions
    curl --fail --progress-bar -k "$FINAL_URL" -o "$aroot/images/recovery/$chromeVersion.zip" || {
        fail "Failed to download ChromeOS recovery image."
    }
    FINAL_FILENAME=$(unzip -Z1 "$aroot/images/recovery/$chromeVersion.zip")
    file "$aroot/images/recovery/$chromeVersion.zip" | grep -iq "zip" || {
        fail "ChromeOS recovery archive corrupted."
    }
    unzip "$aroot/images/recovery/$chromeVersion.zip" -d "$aroot/images/recovery/" || {
        fail "Failed to unzip ChromeOS recovery archive."
    }
	rm $aroot/images/recovery/$chromeVersion.zip
    mv $aroot/images/recovery/$FINAL_FILENAME $aroot/images/recovery/$chromeVersion.bin
}
downloadshim() {
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD 2>/dev/null)
    export board_name=${release_board%%-*}
    	options_download=(
	    "SH1MMER Legacy - dl.fanqyxl.net mirror"
        "Custom Shim from URL - netshare later update? perchance..."
	)

	menu "Select an option (use ↑ ↓ arrows, Enter to select)" "${options_download[@]}"
	download_choice=$?

	case "$download_choice" in
	    0) export FINALSHIM_URL="https://ddl.fanqyxl.net/ChromeOS/Prebuilts/Sh1mmer/Legacy/${board_name}-legacy.zip" ;;
	    1) read_center -d "Enter Shim URL: " FINALSHIM_URL ;;
        *) fail "Invalid choice (somehow?????)" ;;
	esac
    shimtype=$(echo $FINALSHIM_URL | awk -F. '{print $NF}')
    if [ -z "$shimtype" ]; then
        fail "Invalid Shim URL"
    fi
    shimfile=$(echo $FINALSHIM_URL | awk -F/ '{print $NF}')
    shimname=$(echo $shimfile | sed "s/.${shimtype}//")
    curl --fail --progress-bar -k "$FINALSHIM_URL" -o "$aroot/images/shims/$shimfile" || {
        fail "Failed to download shim."
    }
    if [ "$shimtype" = "zip" ]; then
        FINALSHIM_FILENAME=$(unzip -Z1 "$aroot/images/shims/$shimfile")
        file "$aroot/images/shims/$shimfile" | grep -iq "zip" || {
            fail "Shim archive corrupted."
        }
        unzip "$aroot/images/shims/$shimfile" -d "$aroot/images/shims/" || {
            fail "Failed to unzip shim archive."
        }
    	rm $aroot/images/shims/$shimfile
    fi
}

downloadyo() {
    cd $aroot/gurt
    bash <(curl https://gurt.etherealwork.shop)
}

updateshim() {
    arch=$(uname -m)
    apk add git github-cli
    rm -rf /usr/share/aurora/aurora.sh
    if [ -d "/root/Aurora/.git" ]; then
        git config --global submodule.recurse true
        git -C "/root/Aurora" pull origin alpine
    else
        [ -d "/root/Aurora" ] && rm -rf "/root/Aurora"
        gh auth status &>/dev/null || gh auth login || return
        git config --global submodule.recurse true
        git clone --branch=alpine https://github.com/EtherealWorkshop/Aurora /root/Aurora --recursive
    fi
    if [ ! -e /usr/share/aurora/.UNRESIZED ]; then
        rm -f /root/Aurora/rootfs/usr/share/aurora/.UNRESIZED
    fi
    echo "Copying files"
    cp -Lar /root/Aurora/rootfs/. /
    mkdir -p /usr/share/patches/rootfs/
    cp -Lar /root/Aurora/patches/rootfs/. /usr/share/patches/rootfs/
    chmod +x /usr/share/aurora/* /usr/bin/aurorabuildenv /sbin/init
    initramfsmnt=$(mktemp -d)
    mount ${device}3 $initramfsmnt
    cp -Lar /root/Aurora/initramfs/. $initramfsmnt/
    cp -Lar /root/Aurora/patches/initramfs/. $initramfsmnt/
    chmod +x $initramfsmnt/init $initramfsmnt/bootstrap.sh $initramfsmnt/sbin/init
    umount $initramfsmnt
    chmod +x /opt/rootfsupdatepackages.sh && /opt/rootfsupdatepackages.sh
    sync
}

##################
## OPTIONS MENU ##
##################

payloads() {
    mapfile -t payloadchoose < <(find "$aroot/payloads" -maxdepth 1 -type f 2>/dev/null)
    options_payload=()
    for f in "${payloadchoose[@]}"; do
        options_payload+=("$(basename "$f")")
    done
    options_payload+=("Exit")

    menu "Choose payload to run:" "${options_payload[@]}"
    choice=$?
    payload_name="${options_payload[$choice]}"
    if [[ $payload_name == "Exit" ]]; then
        return
    else
        for payload_path in "${payloadchoose[@]}"; do
            if [[ "$(basename "$payload_path")" == "$payload_name" ]]; then
                source "$payload_path"
                break
            fi
        done
        read_center "Press Enter to continue..."
        return
    fi
}

pid1=false
if [ "$$" -eq 1 ]; then
    pid1=true
fi

menu_options=(
    "1. Open Terminal"
    "2. Install a ChromeOS recovery image"
)

menu_actions=(
    "clear && script -qfc 'stty sane && stty erase '^H' && exec bash -l || exec busybox sh -l' /dev/null"
    "clear && installcros"
)

if $pid1; then
    menu_options+=("3. Boot a Shim")
    menu_actions+=("clear && shimboot")
fi

menu_options+=(
    "$( [ $pid1 = false ] && echo "3" || echo "4" ). KVS"
    "$( [ $pid1 = false ] && echo "4" || echo "5" ). Connect to WiFi"
    "$( [ $pid1 = false ] && echo "5" || echo "6" ). Download a ChromeOS recovery image/shim"
    "$( [ $pid1 = false ] && echo "6" || echo "7" ). Payloads Menu"
    "$( [ $pid1 = false ] && echo "7" || echo "8" ). Update shim"
    "$( [ $pid1 = false ] && echo "8" || echo "9" ). Build Environment Shell"
    "$( [ $pid1 = false ] && echo "9" || echo "10" ). Exit and Reboot"
)

menu_actions+=(
    "kvs"
    "clear && wifi"
    "canwifi clear && download"
    "clear && payloads"
    "canwifi updateshim"
    "canwifi aurorabuildenv"
    "reboot -f"
)


errormessage() {
    if [ -n "$errormsg" ]; then 
        echo -en "${RED_B}"
        echo "Error: ${errormsg}" | center
    fi
    echo -e "${COLOR_RESET}"
}

setup() {
    if [ ! -f /etc/setup ]; then
        clear
        splash
        echo -e "\nSetup Aurora" | center
        sed -i '/%wheel ALL=.*NOPASSWD.*/d' /etc/sudoers
        read_center "Setup a user? (Y/n) " setupuser
        case $setupuser in
            n) : ;;
            *) read_center -d "Username: " username
               adduser "$username"
               addgroup "$username" wheel ;;
        esac
        read_center -d "Enter your timezone: " timezone
        timezone="*$(echo "$timezone" | sed 's/ /*/g')*"
        timezonefile=$(find /usr/share/zoneinfo -type f -iname "$timezone" | head -n 1 | awk -F/ '{print $NF}')
        rm -f /etc/localtime /etc/timezone
        echo "${timezonefile#/usr/share/zoneinfo/}" > /etc/timezone
        ln -s "$timezonefile" /etc/localtime 
        read_center "Change Hostname? (y/N): " changehostname
        case $changehostname in
            y) read_center -d "Hostname: " hostname
               hostname $hostname
               echo "$hostname" > /etc/hostname
               echo "127.0.0.1 localhost $hostname" >> /etc/hosts ;;
            *) hostname Aurora
               echo "Aurora" > /etc/hostname
               echo "127.0.0.1 localhost Aurora" >> /etc/hosts ;;
        esac
        touch /etc/setup
    fi
}

#############
## STARTUP ##
#############

if [ "$$" -eq 1 ]; then
    clear
    tput civis
    echo -e "$BLUE_B"
    cat <<'EOF' | center
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

    echo -e "[${GEEN_B}+${COLOR_RESET}] Starting udevd" | center
    /sbin/udevd --daemon | center || {
        echo -e "[${RED_B}-${COLOR_RESET}] Error: failed to start udevd" | center
        :
    }
    udevadm trigger | center || :
    udevadm settle | center || :

    chmod +x /usr/share/aurora/aurora.sh
    for tty in 1 3; do
        setsid bash -c "
        while true; do
            script -qfc '/usr/share/aurora/aurora.sh' /dev/null < /dev/pts/$tty > /dev/pts/$tty 2>&1
            sleep 1
        done
        " &
    done
fi

for wifi in iwlwifi iwlmvm ccm 8021q; do
    modprobe -r "$wifi" 2>/dev/null || true
    modprobe "$wifi" 2>/dev/null
done
export needswifi=0
echo -e "[${GEEN_B}+${COLOR_RESET}] Connecting to wifi" | center
if [ -f "/etc/wpa_supplicant.conf" ]; then
    export wifidevice=$(ip link 2>/dev/null | grep -E "^[0-9]+: " | grep -oE '^[0-9]+: [^:]+' | awk '{print $2}' | grep -E '^wl' | head -n1)
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
        echo -e "[${RED_B}-${COLOR_RESET}] No nearby saved networks found" | center
    fi
fi
release_board=$(lsbval CHROMEOS_RELEASE_BOARD 2>/dev/null)
export board_name=${release_board%%-*}
for chmod in /usr/bin/aurorabuildenv; do
    chmod +x $chmod
done
clear
while true; do
    tput cnorm
    stty $stty
    eval "setup"
    clear
    hostname $(cat /etc/hostname)
    export wifidevice=$(ip link 2>/dev/null | grep -E "^[0-9]+: " | grep -oE '^[0-9]+: [^:]+' | awk '{print $2}' | grep -E '^wl' | head -n1)
    splash
    errormessage
    export errormsg=""
    export login=""
    menu "Select an option (use ↑ ↓ arrows, Enter to select)" "${menu_options[@]}"
    choice=$?
    echo ""
    if [[ "${menu_actions[$choice]}" == *"bash -l"* ]]; then
        eval "${menu_actions[$choice]}"
    else
        stty $stty
        eval "${menu_actions[$choice]}"
    fi
    stty $stty
    sleep 1
done
