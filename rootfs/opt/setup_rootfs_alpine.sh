#!/bin/sh
set -e

arch="${1}"

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
apk add dhcpcd fastfetch figlet util-linux syslog-ng e2fsprogs fish lsblk losetup wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts ncurses udisks2 sudo zram-init iw wpa_supplicant cloud-utils-growpart nano

cat <<'EOF' >> /etc/profile
export PS1='\[\033[1;34m\]$(cat /etc/hostname)\[\e[0m\]:\[\033[1;32m\]\w\[\e[0m\]\$ '

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias toilet="figlet" # those who know
cat /etc/motd
EOF


modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done
echo "Aurora" > /etc/hostname
echo "127.0.0.1 localhost Aurora" >> /etc/hosts
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo root:root | chpasswd