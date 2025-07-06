#!/bin/bash

setsid -c test
set -e
trap '' INT
trap '' SIGINT
trap '' EXIT

dev_partition=$(blkid | grep 'LABEL="Aurora"' | awk -F: '{print $1}')
dev=$(echo "$dev_partition" | sed -E 's/p?[0-9]+$//')

growpart "$dev" 4 || true
resize2fs "$dev_partition" || true
rm -f /.UNRESIZED
echo "Root filesystem expanded."
