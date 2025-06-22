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
if [ -z "$(ls -A "./rootfs")" ]; then
    echo_c "Please run 'sudo bash rootfs.sh [cpu_architecture(x86_64 or aarch64)]'." RED_B
fi

source ./utils/functions.sh
echo_c "Running with flags: ($@)" "BLUE_B"
echo_c "Architecture: ($arch)" "BLUE_B"

shim=$1

dev="$(losetup -Pf --show $shim)"
root="$(cgpt find -l ROOT-A $dev || cgpt find -t rootfs $dev | head -n 1)"
rootmount=$(mktemp -d)

echo -e "y\n" | mkfs.ext4 -F $root
mount $root $rootmount
echo_c "Copying rootfs to shim" "GEEN_B" 
rsync -avH --info=progress2 "./rootfs" "$rootmount"
echo_c "Done!" "GEEN_B"
umount $rootmount
umount $rootmount -l
losetup -D
