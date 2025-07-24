#!/bin/sh
set -e

arch="${1}"

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
apk add jq debootstrap rsync cgpt file unzip dhcpcd tzdata fastfetch figlet util-linux syslog-ng e2fsprogs fish lsblk losetup wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts ncurses udisks2 sudo zram-init iw wpa_supplicant cloud-utils-growpart nano sfdisk sgdisk wget gnupg tar xz zstd
cat <<'EOF' >> /etc/profile
if [ "$USER" = "root" ]; then
  PS1='\e[1;34m\]\u@\h \e[1;33m\]$(date +"%H:%M %b %d")\e[1;32m\] \w/\[\e[0m\] '
else
  PS1='\e[1;31m\]\u@\h \e[1;33m\]$(date +"%H:%M %b %d")\e[1;32m\] \w/\[\e[0m\] '
fi
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias reboot='reboot -f'
alias toilet="figlet" # those who know
echo ""
cat /etc/motd
username=root
read -p "$(hostname) login: " username
sudo -u $username bash -l
EOF


modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done
echo "Aurora" > /etc/hostname
echo "127.0.0.1 localhost Aurora" >> /etc/hosts
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo root:root | chpasswd
rm -f /etc/setup /etc/shimboot
