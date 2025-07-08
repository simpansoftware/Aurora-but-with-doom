#!/bin/bash

setsid -c test
set -e
trap '' INT
trap '' SIGINT
trap '' EXIT

dev_partition=$(blkid | grep 'LABEL="Aurora"' | awk -F: '{print $1}')
dev=$(echo "$dev_partition" | sed -E 's/p?[0-9]+$//')

parted -fs $dev align-check opt 4
echo "Say yes"
parted $dev resizepart 4 100%
resize2fs "$dev_partition"
rm -f /.UNRESIZED