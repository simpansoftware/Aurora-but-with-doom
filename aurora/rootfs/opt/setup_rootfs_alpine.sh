#!/bin/sh
set -e

arch="${1}"

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
EOF
apk add dhcpcd fastfetch figlet util-linux syslog-ng e2fsprogs fish lsblk losetup wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts networkmanager networkmanager-cli ncurses udisks2 sudo zram-init networkmanager networkmanager-tui networkmanager-wifi wpa_supplicant cloud-utils-growpart nano



modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done

alias toilet="figlet" # those who know
echo "cat /etc/motd" >> /etc/profile

echo "aurora" > /etc/hostname
echo "127.0.0.1 localhost aurora" >> /etc/hosts
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo root:root | chpasswd