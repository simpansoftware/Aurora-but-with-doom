#!/bin/bash
if [ -z "$@" ]; then
    echo "Usage: sudo bash changeshim.sh /path/to/rawshim.bin /path/to/aurorashim.bin"
    exit 1
fi
shim=$1
aurorashim=$2
shimdev="$(losetup -Pf --show $shim)"
aurorashimdev="$(losetup -Pf --show $aurorashim)"
skpart="$(cgpt find -l KERN-A $shimdev | head -n 1)"
auroraskpart="$(cgpt find -l KERN-A $aurorashimdev | head -n 1)"
skpartnum="$(echo $skpart | sed "s|${shimdev}p||")"
skguid="$(sgdisk -i $skpartnum "$shimdev")"
dd if=$skpart of=$auroraskpart
sgdisk --partition-guid=2:B5BAF579-07EF-A747-858B-87C0E507CD29 "$dev"
cgpt add -i 2 -t "$(cgpt show -i $skpartnum -t "$shimdev")" -l "$(cgpt show -i $skpartnum -l "$shimdev")" -P 15 -T 15 -S 1 "$aurorashimdev"

chromeos="$(cgpt find -l ROOT-A $shimdev | head -n 1)"
aurorapart="$(cgpt find -l Aurora $shimdev | head -n 1)"
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