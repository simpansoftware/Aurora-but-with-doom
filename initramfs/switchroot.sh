#!/bin/busybox sh
echo "Making the newroot partition..."
mkdir -p /newroot
dev_partition=$(blkid | grep 'LABEL="Aurora"' | awk -F: '{print $1}' || true)
dev=$(echo "$dev_partition" | sed -E 's/p?[0-9]+$//')
if [ -z "$dev_partition" ]; then
    echo "failed to find aurora partition"
    exit 1
fi
if [ -f "/.UNRESIZED" ]; then
    chmod +x /.UNRESIZED
    bash /.UNRESIZED
    rm -f /.UNRESIZED
    sync
fi
echo "Mounting device..."
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs dev /dev
mount -t devpts devpts /dev/pts
mount $dev_partition /newroot || mount /dev/sda4 /newroot || mount /dev/mmcblk1p4 /newroot # incase of thuggery from dev_partition
for mnt in /dev /proc /sys /dev/pts; do
    mkdir -p "/newroot$mnt"
    mount --move "$mnt" "/newroot$mnt"
done

echo "pivoting root"
mkdir -p /newroot/initramfs
pivot_root /newroot /newroot/initramfs
umount -l /initramfs
chmod +x /sbin/init
echo "exec /sbin/init"
exec /sbin/init < "$TTY1" >> "$TTY1"