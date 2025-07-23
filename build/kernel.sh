#!/bin/bash
if [ ! -e "$1" ] || [ ! -e "$2" ]; then
    echo "Usage: sudo bash kernel.sh /path/to/rawshim.bin /path/to/aurorashim.bin"
    exit 1
fi
if [ "$3" = "--device" ]; then
    aurorashimdev="$2"
else
    aurorashim=$2
    aurorashimdev="$(losetup -Pf --show $aurorashim)"
fi
source ./utils/functions.sh
shim=$1
shimdev="$(losetup -Pf --show $shim)"
skpart="$(cgpt find -l KERN-A $shimdev | head -n 1)"
auroraskpart="$(cgpt find -l KERN-A $aurorashimdev | head -n 1)"
skpartnum="$(echo $skpart | sed "s|${shimdev}p||")"
skguid="$(sgdisk -i $skpartnum "$shimdev")"
dd if=$skpart of=$auroraskpart
sgdisk --partition-guid=2:B5BAF579-07EF-A747-858B-87C0E507CD29 "$aurorashimdev"
cgpt add -i 2 -t "$(cgpt show -i $skpartnum -t "$shimdev")" -l "$(cgpt show -i $skpartnum -l "$shimdev")" -P 15 -T 15 -S 1 "$aurorashimdev"

chromeos="$(cgpt find -l ROOT-A $shimdev | head -n 1)"
aurorapart="$(cgpt find -l Aurora $aurorashimdev | head -n 1)"
tempmount="$(mktemp -d)"
auroratempmount="$(mktemp -d)"
echo_c "Copying Modules..." GEEN_B
mount -o ro $chromeos $tempmount
mount $aurorapart $auroratempmount
if [ -d $tempmount/lib/modules ]; then
    cp -ar $tempmount/lib/modules $auroratempmount/lib/
    cp -ar $tempmount/etc/lsb-release $auroratempmount/etc/lsb-release
    umount $tempmount
    umount $auroratempmount
else
    echo_c "Please run on a raw shim." RED_B
    exit
fi
losetup -D