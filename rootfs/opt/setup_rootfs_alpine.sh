#!/bin/sh

setup-hostname "Aurora"
cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
apk add adw-gtk3 bash cgpt cloud-utils-growpart coreutils curl dbus debootstrap e2fsprogs elogind file fish fastfetch figlet gnupg gzip htop iw jq lsblk losetup lz4 lzo mtools mousepad nano ncurses network-manager-applet networkmanager networkmanager-tui networkmanager-wifi ncurses openrc polkit-elogind polkit sudo sfdisk sgdisk syslog-ng tar tpm2-tools udev-init-scripts udisks2 unzip util-linux vboot-utils wget xz zstd zram-init wpa_supplicant
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
rc-update add networkmanager default
rc-update add wpa_supplicant default
rc-update add zram-init default
rc-update add elogind default
rc-update add dbus default

modules="$(ls /etc/modules-load.d)"
for module in $modules; do
  cat "/etc/modules-load.d/$module" >> /etc/modules
  echo >> /etc/modules
done
cat <<'EOF' >> /etc/profile
export PS1='\[\033[1;34m\]Aurora\[\e[0m\]:\[\033[1;32m\]\w\[\e[0m\]\$ '
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias reboot='reboot -f'
alias toilet="figlet" # those who know
cat /etc/motd
EOF

sed -i 's/=zstd/=lzo/' /etc/conf.d/zram-init
sed -i '/size0=512/d' /etc/conf.d/zram-init
sed -i '/blk1=1024/d' /etc/conf.d/zram-init
echo "size0=\`LC_ALL=C free -m | awk '/^Mem:/{print int(\$2/2)}'\`" >> /etc/conf.d/zram-init

mkdir -p /etc/NetworkManager/conf.d
echo -e "[main]\nauth-polkit=false" > /etc/NetworkManager/conf.d/any-user.conf

useradd -m user
usermod -G netdev -a user
usermod -G plugdev -a user
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "root:root" | chpasswd
usermod -a -G wheel user

echo "user:user" | chpasswd
