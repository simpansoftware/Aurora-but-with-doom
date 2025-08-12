#!/bin/sh

setup-hostname Aurora

cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
apk add jq debootstrap rsync iwd cgpt file unzip dhcpcd tzdata fastfetch figlet util-linux syslog-ng e2fsprogs fish lsblk losetup wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash openrc dbus eudev udev-init-scripts ncurses udisks2 sudo zram-init iw wpa_supplicant cloud-utils-growpart nano sfdisk sgdisk wget gnupg tar xz zstd >/dev/null

rc-update add acpid default
rc-update add bootmisc boot
rc-update add crond default
rc-update add devfs sysinit
rc-update add sysfs sysinit
rc-update add dmesg sysinit
rc-update add hostname boot
rc-update add hwclock boot
rc-update add hwdrivers sysinit
rc-update add killprocs shutdown
rc-update add mdev sysinit
rc-update add modules boot
rc-update add mount-ro shutdown
rc-update add networking boot
rc-update add savecache shutdown
rc-update add seedrng boot
rc-update add swap boot
rc-update add syslog boot
chmod +x /etc/init.d/aurora
rc-update add aurora boot

rc-update add iwd default
rc-update add wpa_supplicant default
rc-update add zram-init default
rc-update add dbus default

sed -i 's/=zstd/=lzo/' /etc/conf.d/zram-init
sed -i '/size0=512/d' /etc/conf.d/zram-init
sed -i '/blk1=1024/d' /etc/conf.d/zram-init
echo "size0=\`LC_ALL=C free -m | awk '/^Mem:/{print int(\$2/2)}'\`" >> /etc/conf.d/zram-init

cat <<'EOF' >> /etc/profile
if [ "$USER" = "root" ]; then
  PS1='\e[1;31m\u@\h \e[1;33m$(date +"%H:%M %b %d")\e[1;32m \w/\e[0m '
else
  PS1='\e[1;34m\u@\h \e[1;33m$(date +"%H:%M %b %d")\e[1;32m \w/\e[0m '
fi

export TERM=xterm-direct
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias reboot='reboot -f'
alias toilet="figlet" # those who know

echo ""
if [ -z "$login" ]; then
  cat /etc/motd
  stty intr ''
  read -p "$(hostname) login: " USER
  stty intr '^C'
  export login=1
  exec sudo -u "$USER" login=1 bash -l
fi
EOF



modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo root:root | chpasswd 2>/dev/null
rm -f /etc/setup /etc/shimboot
