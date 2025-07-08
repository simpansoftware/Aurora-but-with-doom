#!/bin/bash

if [[ "$(basename "$(pwd)")" != "build" ]]; then
    echo "Please run in the build directory. (Aurora/build/)"
    exit 1
fi
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi
if [ -z "$1" ]; then
    echo "Usage: sudo bash rootfs.sh /path/to/rawshim.bin [cpu_architecture(x86_64 or aarch64)]"
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

checkarch() {
    if [[ "$arch" != "aarch64" && "$arch" != "x86_64" ]]; then
        echo -e "Invalid CPU Architecture"
        read -p "Enter CPU Architecture (x86_64/aarch64): " arch
        export arch
        checkarch
    fi
}
checkarch

shim="$1"

source ./utils/functions.sh
echo_c "Architecture: ($arch)" BLUE_B
echo_c "Shim: ($1)" "BLUE_B"


initramfs=$(realpath -m "./initramfs")
rootfs=$(realpath -m "./rootfs")
buildrootfs=$(realpath -m "./buildrootfs")

rm -rf "${rootfs}" 
mkdir -p "${rootfs}"

if findmnt -T "$rootfs" -o OPTIONS -n | grep -qE 'noexec|nodev'; then
    mount -o remount,dev,exec "$(findmnt -T "$rootfs" -o TARGET -n)"
fi

echo_c "Bootstrapping Alpine" GEEN_B

if [ ! -f alpine-minirootfs.tar.gz ]; then
    curl -L https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/$arch/alpine-minirootfs-3.22.0-$arch.tar.gz -o alpine-minirootfs.tar.gz
fi
tar -xf alpine-minirootfs.tar.gz -C $rootfs
rm -f $rootfs/sbin/init

echo "nameserver 8.8.8.8" > $rootfs/etc/resolv.conf
# haha 69
for arg in "$@"; do
    case "$arg" in
        --nowifi|-nw)
            export NOWIFI=true
            ;;
    esac
done

unmount() {
    for dir in proc sys dev run; do
        umount -l "$rootfs/$dir"
    done
}
trap unmount EXIT
cp -Lar $rootfs/. $initramfs/
cp -r ../initramfs/. $initramfs/
chroot "$initramfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_initramfs_alpine.sh && /opt/setup_initramfs_alpine.sh $arch"
cp -r ../rootfs/. $rootfs/
chroot "$rootfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_rootfs_alpine.sh && /opt/setup_rootfs_alpine.sh $arch"

if [ "$NOWIFI" = true ]; then
    echo_c "Flag 'nowifi' set. Skipping firmware download..." YELLOW_B
else
    echo_c "Downloading firmware..." GEEN_B
    [ ! -d "linux-firmware" ] && git clone --depth=1 https://chromium.googlesource.com/chromiumos/third_party/linux-firmware $rootfs/lib/firmware/
fi

rm -rf $(find $rootfs/lib/firmware/* -not -name "*wifi*")

trap - EXIT
unmount

echo_c "Rootfs Created" GEEN_B
echo_c "Done!" GEEN_B