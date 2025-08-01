#!/bin/bash

shim="$1"
arch="$2"
source ../patches/functions.sh

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
cp -r ../patches/initramfs/. "$initramfs/"
chroot "$initramfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_initramfs_alpine.sh && /opt/setup_initramfs_alpine.sh $arch"
cp -r ../rootfs/. $rootfs/
mkdir -p $rootfs/usr/share/patches/rootfs
cp -r ../patches/rootfs/. "$rootfs/usr/share/patches/rootfs/"
chroot "$rootfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_rootfs_alpine.sh && /opt/setup_rootfs_alpine.sh $arch"

if [ "$NOWIFI" = true ]; then
    echo_c "Flag 'nowifi' set. Skipping firmware download..." YELLOW_B
else
    echo_c "Downloading firmware..." GEEN_B
    git clone --depth=1 https://chromium.googlesource.com/chromiumos/third_party/linux-firmware $rootfs/lib/firmware/ # haha 69
fi

rm -rf $(find $rootfs/lib/firmware/* -not -path "*wifi*")

trap - EXIT
unmount

echo_c "Rootfs Created" GEEN_B
echo_c "Done!" GEEN_B