#!/bin/bash

source /etc/profile

echo "Populating /dev, /proc, /sys..."

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmp /tmp

mount -t devtmpfs devtmpfs /dev
if ! mount | grep -q '^devtmpfs'; then
echo "Creating /dev nodes..."

    mkdir -p /dev
    mknod -m 666 /dev/null c 1 3
    mknod -m 666 /dev/zero c 1 5
    mknod -m 666 /dev/full c 1 7
    mknod -m 666 /dev/random c 1 8
    mknod -m 666 /dev/urandom c 1 9
    mknod -m 666 /dev/tty c 5 0
    mknod -m 600 /dev/console c 5 1
fi
if [ -d /proc/self/fd ] && [ ! -e /dev/fd ]; then
    ln -s /proc/self/fd /dev/fd || echo "Uh oh!"
fi
ln -snf fd/0 /dev/stdin || :
ln -snf fd/1 /dev/stdout || :
ln -snf fd/2 /dev/stderr || :

mkdir -p /dev/pts
mount -n -t devpts -o noexec,nosuid devpts /dev/pts || :

mount -n -t debugfs debugfs /sys/kernel/debug

echo "Done."
