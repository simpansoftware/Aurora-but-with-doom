#!/bin/bash

if [[ "$(basename "$(pwd)")" != "build" ]]; then
    echo "Please run in the build directory. (Aurora/build/)"
    exit 1
fi

source ./utils/functions.sh

echo_c "Running with flags: ($@)" GEEN_B
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

rootfs=$(realpath -m "./rootfs")
buildrootfs=$(realpath -m "./buildrootfs")
arch="${args[arch]:-x86_64}"

rm -rf "${rootfs}" & mkdir -p "${rootfs}"

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

echo "nameserver 8.8.8.8" > $rootfs/etc/resolv.conf
echo "aurora" > $rootfs/etc/hostname # we do a bit of self-advertising
cp -r ../rootfs/* $rootfs
rm $rootfs/sbin/init

for arg in "$@"; do
    case "$arg" in
        --nowifi|-nw)
            export NOWIFI=true
            ;;
    esac
done
if [ "$NOWIFI" = true ]; then
    log_info "Flag 'nowifi' set. Skipping firmware download..."
else
    log_info "Downloading firmware..."
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

chroot $rootfs /bin/sh -c "/opt/setup_rootfs_alpine.sh $arch"

trap - EXIT
unmount

echo_c "Rootfs Created" GEEN_B