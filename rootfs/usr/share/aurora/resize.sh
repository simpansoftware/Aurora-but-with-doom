#!/bin/bash

setsid -c test >/dev/null 2>&1
set -e
trap '' INT
trap '' SIGINT
trap '' EXIT

dev_partition=$(blkid | grep 'LABEL="Aurora"' | awk -F: '{print $1}')
dev=$(echo "$dev_partition" | sed -E 's/p?[0-9]+$//')

growpart "$dev" 4 >/dev/null 2>&1 || true
resize2fs "$dev_partition" >/dev/null 2>&1 || true
rm -f /.UNRESIZED >/dev/null 2>&1
echo "Root filesystem expanded." >/dev/null 2>&1
