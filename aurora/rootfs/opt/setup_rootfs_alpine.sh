#!/bin/sh
set -e

arch="${10}"

echo "$hostname" > /etc/hostname
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
apk add wpa_supplicant vboot-utils curl tpm2-tools cryptsetup
apk del apk-tools
rm -rf /lib/rc
rm -rf /var/cache
rm /sbin/eapol_test
rm /usr/lib/libstdc++* /usr/lib/libunistring*
rm -rf /usr/share/vboot\
