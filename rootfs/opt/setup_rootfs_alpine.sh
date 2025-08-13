#!/bin/sh

setup-hostname Aurora

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
apk add jq debootstrap rsync iwd cgpt file unzip dhcpcd tzdata fastfetch figlet util-linux syslog-ng e2fsprogs fish lsblk losetup wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts ncurses udisks2 sudo zram-init iw wpa_supplicant cloud-utils-growpart nano sfdisk sgdisk wget gnupg tar xz zstd >/dev/null

for module in $(ls /etc/modules-load.d); do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done

echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo root:root | chpasswd 2>/dev/null
rm -f /etc/setup /etc/shimboot
