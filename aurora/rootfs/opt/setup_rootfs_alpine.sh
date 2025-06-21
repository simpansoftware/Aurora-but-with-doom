#!/bin/sh
set -e

arch="${1}"

echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
apk add wpa_supplicant vboot-utils curl tpm2-tools cryptsetup coreutils bash
