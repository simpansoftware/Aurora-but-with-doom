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
    arch="$1"
    export arch
fi

source ./utils/functions.sh
echo_c "Architecture: ($arch)" BLUE_B

rootfs=$(realpath -m "./rootfs")
buildrootfs=$(realpath -m "./buildrootfs")

rm -rf "${rootfs}" 
mkdir -p "${rootfs}"

need_remount() {
    findmnt -T "$1" -o OPTIONS -n | grep -qE 'noexec|nodev'
}

do_remount() {
    mount -o remount,dev,exec "$(findmnt -T "$1" -o TARGET -n)"
}

if need_remount "$rootfs"; then
    do_remount "$rootfs"
fi

echo_c "Bootstrapping Alpine" GEEN_B

if [ ! -f alpine-minirootfs.tar.gz ]; then
    curl -L https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/$arch/alpine-minirootfs-3.22.0-$arch.tar.gz -o alpine-minirootfs.tar.gz
fi
tar -xf alpine-minirootfs.tar.gz -C $rootfs

rm $rootfs/sbin/init
cp -r ../rootfs/* $rootfs

rm -rf $(find "$rootfs/lib/firmware/"* \
    -not -name "iwlwifi-7265D-29.ucode.ucode" \
    -not -name "iwlwifi-9000-pu-b0-jf-b0-41.ucode" \
    -not -name "iwlwifi-QuZ-a0-hr-b0-57.ucode" \
    -not -name "iwlwifi-so-a0-gf-a0-83.ucode")

echo "nameserver 8.8.8.8" > $rootfs/etc/resolv.conf
echo "aurora" > $rootfs/etc/hostname # we do a bit of self-advertising
# haha 69
for arg in "$@"; do
    case "$arg" in
        --nowifi|-nw)
            export NOWIFI=true
            ;;
    esac
done
if [ "$NOWIFI" = true ]; then
    echo_c "Flag 'nowifi' set. Skipping firmware download..." YELLOW_B
else
    echo_c "Downloading firmware..." GEEN_B
    [ ! -d "linux-firmware" ] && git clone --depth=1 https://chromium.googlesource.com/chromiumos/third_party/linux-firmware $rootfs/lib/firmware/
fi
unmount() {
    for dir in proc sys dev run; do
        umount -l "$rootfs/$dir"
    done
}
trap unmount EXIT
for dir in proc sys dev run; do
    mount --make-rslave --rbind "/$dir" "$rootfs/$dir"
done

chroot $rootfs /bin/sh -c "chmod +x /opt/setup_rootfs_alpine.sh && /opt/setup_rootfs_alpine.sh $arch"

trap - EXIT
unmount

echo_c "Rootfs Created" GEEN_B