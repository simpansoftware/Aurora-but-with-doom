#!/bin/bash

# Copyright 2025 Ethereal Workshop. All rights reserved.
# Use of this source code is governed by the BSD 3-Clause license
# that can be found in the LICENSE.md file.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

shim=$1

source ./utils/functions.sh

aurorashim="../$(basename "${shim%.*}")-aurora.bin"
if [ -z $shim ]; then
    echo_c "Please specify a valid rawshim file." RED_B
fi
rootfs="./rootfs/"
initramfs="./initramfs/"

if [ -z "$(ls -A "$rootfs")" ]; then
    echo_c "Please run 'sudo bash rootfs.sh [cpu_architecture(x86_64 or aarch64)]'." RED_B
fi

mkdir -p "$initramfs"
rm -f $aurorashim
truncate -s 694200K "$aurorashim" # haha 69

shimdev="$(losetup -Pf --show $shim)"
dev="$(losetup -Pf --show $aurorashim)"
lsbval() {
  local key="$1"
  local lsbfile="${2:-./rootfs/etc/lsb-release}"

  if ! echo "${key}" | grep -Eq '^[a-zA-Z0-9_]+$'; then
    return 1
  fi

  sed -E -n -e \
    "/^[[:space:]]*${key}[[:space:]]*=/{
      s:^[^=]+=[[:space:]]*::
      s:[[:space:]]+$::
      p
    }" "${lsbfile}"
}
chromeos="$(cgpt find -l ROOT-A $shimdev | head -n 1)"
tempmount="$(mktemp -d)"
echo_c "Copying Modules..." GEEN_B
mount -o ro $chromeos $tempmount
if [ -d $tempmount/lib/modules ]; then
    cp -ar $tempmount/lib/modules ./rootfs/lib/
    cp -ar $tempmount/etc/lsb-release ./rootfs/etc/lsb-release
    export boardname=$(lsbval CHROMEOS_RELEASE_BOARD)
    umount $tempmount
else
    echo_c "Please run on a raw shim." RED_B
    exit
fi

sgdisk --zap-all "$dev"

sgdisk -n 1:2048:10239 -c 1:"STATE" "$dev"
sgdisk -n 2:10240:75775    "$dev"
sgdisk -n 3:75776:137215 -c 3:"ROOT-A" "$dev"
sgdisk -n 4:137216:0 -c 4:"Aurora" "$dev"


sgdisk -t 3:3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC "$dev"
sgdisk -t 4:8300 "$dev"

sgdisk -p "$dev"

kernelpartition="${dev}p2"


skpart="$(cgpt find -l KERN-A $shimdev | head -n 1)"
skpartnum="$(echo $skpart | sed "s|${shimdev}p||")"
skguid="$(sgdisk -i $skpartnum "$shimdev")"
dd if=$skpart of=$kernelpartition


sgdisk --partition-guid=2:B5BAF579-07EF-A747-858B-87C0E507CD29 "$dev"
cgpt add -i 2 -t "$(cgpt show -i $skpartnum -t "$shimdev")" -l "$(cgpt show -i $skpartnum -l "$shimdev")" -P 15 -T 15 -S 1 "$dev"

state="${dev}p1"
root_a="${dev}p3"
root_b="${dev}p4"

echo -e "y\n" | mkfs.ext4 "$state" -L STATE
echo -e "y\n" | mkfs.ext4 "$root_a" -L ROOT-A
echo -e "y\n" | mkfs.ext4 "$root_b" -L Aurora

statemount=$(mktemp -d)
root_amount=$(mktemp -d)
root_bmount=$(mktemp -d)
mount $state $statemount
mkdir -p $statemount/dev_image/etc/
touch $statemount/dev_image/etc/lsb-factory
mount $root_a $root_amount
mount $root_b $root_bmount

echo_c "Copying rootfs to shim" "GEEN_B" 
rm -f $root_bmount/sbin/init
cp ../rootfs/. $rootfs -ar
rsync -avH --info=progress2 "$rootfs" "$root_bmount" &>/dev/null
echo_c "Copying initramfs to shim" "GEEN_B" 
rm -f $root_amount/bin/init
cp ../initramfs/. $initramfs -ar
rsync -avH --info=progress2 "$initramfs" "$root_amount" &>/dev/null
chmod +x $root_amount/sbin/init
chmod +x $root_bmount/sbin/init
echo_c "Unmounting..." "GEEN_B"
umount $statemount
umount $statemount -l
umount $root_amount
umount $root_amount -l
umount $root_bmount
umount $root_bmount -l
losetup -D
mv $aurorashim ../${boardname}-aurora.bin
export finalshim="${boardname}-aurora.bin"
