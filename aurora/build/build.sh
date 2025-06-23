#!/bin/bash

if [[ "$(basename "$(pwd)")" != "build" ]]; then
    echo "Please run in the build directory. (Aurora/build/)"
    exit 1
fi
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi
checkarch() {
    if [[ "$arch" != "aarch64" && "$arch" != "x86_64" ]]; then
        echo -e "Invalid CPU Architecture\n"
        read -p "Enter CPU Architecture (x86_64/aarch64): " arch
        export arch
        checkarch
    fi
}
if [ -z "$1" ]; then
    echo "Usage: sudo bash build.sh /path/to/rawshim.bin [cpu_architecture(x86_64 or aarch64)]"
    exit 1
fi
if [ -z "$2" ]; then
    read -p "CPU Architecture Unspecified. Default to x86_64? (Y/n): " cpuarch
    case "$cpuarch" in
        n|N)
            read -p "Enter CPU Architecture (x86_64/aarch64): " arch
            export arch
            ;;
        *)
            arch="x86_64"
            export arch
            ;;
    esac
else
    arch="$2"
    export arch
fi

shim=$1
rootfs="./rootfs/"
initramfs="./initramfs/"

if [ -z "$(ls -A "$rootfs")" ]; then
    echo_c "Please run 'sudo bash rootfs.sh [cpu_architecture(x86_64 or aarch64)]'." RED_B
fi

mkdir -p "$initramfs"

source ./utils/functions.sh
echo_c "Running with flags: ($@)" "BLUE_B"
echo_c "Architecture: ($arch)" "BLUE_B"

dev="$(losetup -Pf --show $shim)"

printf "%s\n" \
  d 12 \
  d 11 \
  d 10 \
  d 9 \
  d 8 \
  d 7 \
  d 6 \
  d 5 \
  d 4 \
  d 3 \
  n 3 "" "+20M" \
  n 4 "" "" \
  t 3 175 \
  t 4 20 \
  w | fdisk "$dev"


root_a="${dev}p3"
root_b="${dev}p4"

echo -e "y\n" | mkfs.ext4 "$root_a" -L ROOT-A
echo -e "y\n" | mkfs.ext4 "$root_b" -L ROOT-B

root_amount=$(mktemp -d)
root_bmount=$(mktemp -d)
mount $root_a $root_amount
mount $root_b $root_bmount

echo_c "Copying rootfs to shim" "GEEN_B" 
rsync -avH --info=progress2 "$rootfs" "$root_bmount"
echo_c "Copying initramfs to shim" "GEEN_B" 
rsync -avH --info=progress2 "$initramfs" "$root_amount"
rm -f $root_amount/sbin/init
cp ../root-a/sbin/init $root_amount/sbin/init
chmod +x $root_amount/sbin/init
chmod +x $root_bmount/sbin/init
echo_c "Done!" "GEEN_B"
umount $root_amount
umount $root_amount -l
umount $root_bmount
umount $root_bmount -l
losetup -D
