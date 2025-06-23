#!/bin/sh
set -e

arch="${1}"

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
EOF
apk add syslog-ng acpid cronie wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts networkmanager ncurses elogind polkit-elogind udisks2 polkit-elogind sudo zram-init networkmanager networkmanager-tui networkmanager-wifi network-manager-applet wpa_supplicant adw-gtk3 cloud-utils-growpart nano mousepad

rc-update add acpid default
rc-update add bootmisc boot
rc-update add cronie default
rc-update add devfs sysinit
rc-update add sysfs sysinit
rc-update add dmesg sysinit
rc-update add hostname boot
rc-update add hwclock boot
rc-update add hwdrivers sysinit
rc-update add killprocs shutdown
rc-update add modules boot
rc-update add mount-ro shutdown
rc-update add savecache shutdown
rc-update add seedrng boot
rc-update add swap boot
rc-update add syslog-ng boot
rc-update add dbus default



modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo root:root | chpasswd