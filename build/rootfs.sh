#!/bin/bash

# Copyright 2025 Ethereal Workshop. All rights reserved.
# BSD 3-Clause License

source ./utils/functions.sh

initramfs=$(realpath -m "./initramfs")
rootfs=$(realpath -m "./rootfs")

originalarch=$2
case "$originalarch" in
    x86_64) arch=amd64 ;;
    aarch64) arch=arm64 ;;
    amd64) originalarch=x86_64 ;;
    arm64) originalarch=aarch64 ;;
    *) echo "Unsupported arch."; exit 1 ;;
esac

###############
## INITRAMFS ##
###############

rm -rf "$initramfs"
mkdir -p "$initramfs"

echo_c "Bootstrapping initramfs" GEEN_B

if [ ! -f alpine-minirootfs.tar.gz ]; then
    curl -L "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/$originalarch/alpine-minirootfs-3.22.0-$originalarch.tar.gz" -o alpine-minirootfs.tar.gz
fi

tar -xf alpine-minirootfs.tar.gz -C "$initramfs"
rm -f "$initramfs/sbin/init"

echo "nameserver 8.8.8.8" > "$initramfs/etc/resolv.conf"
cp -r ../initramfs/. "$initramfs/"

unmountinitram() {
    for dir in proc sys dev run; do
        umount -l "$initramfs/$dir" 2>/dev/null || true
    done
}
trap unmountinitram EXIT

chroot "$initramfs" /bin/sh -c \
  "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_initramfs_alpine.sh && /opt/setup_initramfs_alpine.sh $arch"

trap - EXIT
unmountinitram

############
## ROOTFS ##
############

rm -rf "$rootfs"
mkdir -p "$rootfs"

packages="alpine-base"

if findmnt -T "$rootfs" -o OPTIONS -n | grep -qE 'noexec|nodev'; then
    mount -o remount,dev,exec "$(findmnt -T "$rootfs" -o TARGET -n)"
fi

echo_c "Downloading alpine package list" GEEN_B
pkg_list_url="https://dl-cdn.alpinelinux.org/alpine/edge/main/$originalarch/"
pkg_data="$(wget -qO- --show-progress "$pkg_list_url" | grep "apk-tools-static")"
pkg_url="$pkg_list_url$(echo "$pkg_data" | pcregrep -o1 '"(.+?.apk)"')"

echo_c "Downloading and extracting apk-tools-static" GEEN_B
pkg_extract_dir="/tmp/apk-tools-static"
pkg_dl_path="$pkg_extract_dir/pkg.apk"
apk_static="$pkg_extract_dir/sbin/apk.static"
mkdir -p "$pkg_extract_dir"
wget -q --show-progress "$pkg_url" -O "$pkg_dl_path"
tar --warning=no-unknown-keyword -xzf "$pkg_dl_path" -C "$pkg_extract_dir"

echo_c "Bootstrapping alpine rootfs" GEEN_B
real_arch="$originalarch"
"$apk_static" --arch "$real_arch" -X "http://dl-cdn.alpinelinux.org/alpine/edge/main/" -U --allow-untrusted --root "$rootfs" --initdb add $packages

echo_c "Creating bind mounts for chroot" GEEN_B
unmount_rootfs() {
  for mountpoint in proc sys dev run; do
    umount -l "$rootfs/$mountpoint" 2>/dev/null || true
  done
}
trap unmount_rootfs EXIT

for mountpoint in proc sys dev run; do
  mount --make-rslave --rbind "/$mountpoint" "$rootfs/$mountpoint"
done

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
    git clone --depth=1 https://chromium.googlesource.com/chromiumos/third_party/linux-firmware "$rootfs/lib/firmware/"
    rm -rf $(find "$rootfs/lib/firmware/"* -not -path "*wifi*")
fi

echo "nameserver 8.8.8.8" > "$rootfs/etc/resolv.conf"

echo_c "Setting up rootfs" GEEN_B
cp -r ../rootfs/. "$rootfs/"
LC_ALL=C chroot "$rootfs" /bin/sh -c \
  "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_rootfs_alpine.sh && /opt/setup_rootfs_alpine.sh $arch"

trap - EXIT
unmount_rootfs

echo_c "Rootfs Created" GEEN_B
echo_c "Done!" GEEN_B
