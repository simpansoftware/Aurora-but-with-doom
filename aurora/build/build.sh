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

if [[ "$(basename "$(pwd)")" != "build" ]]; then
    echo "Please run in the build directory. (Aurora/build/)"
    exit 1
fi
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi
if [ -z "$1" ]; then
    echo "Usage: sudo bash build.sh /path/to/rawshim.bin [cpu_architecture(x86_64 or aarch64)]"
    exit 1
fi
if [ -z "$2" ]; then
    read -p "CPU Architecture Unspecified. Default to x86_64? (Y/n): " cpuarch
    case "$cpuarch" in
        n|N)
            read -p "Enter CPU Architecture (x86_64/aarch64): " arch
            export arch
            ;;
        *)
            arch="x86_64"
            export arch
            ;;
    esac
else
    arch="$2"
    export arch
fi
checkarch() {
    if [[ "$arch" != "aarch64" && "$arch" != "x86_64" ]]; then
        echo -e "Invalid CPU Architecture\n"
        read -p "Enter CPU Architecture (x86_64/aarch64): " arch
        export arch
        checkarch
    fi
}
shim=$1
aurorashim="./$(basename "${shim%.*}")-aurora.bin"
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

source ./utils/functions.sh
echo_c "Shim: ($1)" "BLUE_B"
echo_c "Architecture: ($arch)" "BLUE_B"

shimdev="$(losetup -Pf --show $shim)"
dev="$(losetup -Pf --show $aurorashim)"

chromeos="$(cgpt find -l ROOT-A $shimdev | head -n 1)"
tempmount="$(mktemp -d)"
echo_c "Copying Modules..." GEEN_B
mount -o ro $chromeos $tempmount
if [ -d $tempmount/lib/modules ]; then
    cp -ar $tempmount/lib/modules ./rootfs/lib/
    umount $tempmount
else
    echo_c "Please run on a raw shim." RED_B
    exit
fi

sgdisk --zap-all "$dev"

sgdisk -n 1:2048:10239     "$dev"
sgdisk -n 2:10240:75775    "$dev"
sgdisk -n 3:75776:96255 -c 3:"ROOT-A" "$dev"
sgdisk -n 4:96256:1387183 -c 4:"Aurora" "$dev"

sgdisk -t 3:3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC "$dev"
sgdisk -t 4:8300 "$dev"

sgdisk -p "$dev"

skpart="$(cgpt find -l KERN-A $shimdev | head -n 1)"
sspart="$(cgpt find -l STATE $shimdev | head -n 1)"
skpartnum="$(echo $skpart | sed "s|${shimdev}p||")"
sspartnum="$(echo $sspart | sed "s|${shimdev}p||")"
skguid="$(sgdisk -i $skpartnum "$shimdev")"

kernelpartition="${dev}p2"
statepartition="${dev}p1"

dd if=$skpart of=$kernelpartition
dd if=$sspart of=$statepartition


sgdisk --partition-guid=2:B5BAF579-07EF-A747-858B-87C0E507CD29 "$dev"
cgpt add -i 2 -t "$(cgpt show -i $skpartnum -t "$shimdev")" -l "$(cgpt show -i $skpartnum -l "$shimdev")" -P 15 -T 15 -S 1 "$dev"
cgpt add -i 1 -t "$(cgpt show -i $sspartnum -t "$shimdev")" -l "$(cgpt show -i $sspartnum -l "$shimdev")" "$dev"


root_a="${dev}p3"
root_b="${dev}p4"

echo -e "y\n" | mkfs.ext4 "$root_a" -L ROOT-A
echo -e "y\n" | mkfs.ext4 "$root_b" -L Aurora


root_amount=$(mktemp -d)
root_bmount=$(mktemp -d)
mount $root_a $root_amount
mount $root_b $root_bmount

echo_c "Copying rootfs to shim" "GEEN_B" 
cp ../rootfs/* rootfs/ -r
rsync -avH --info=progress2 "$rootfs" "$root_bmount"
echo_c "Copying initramfs to shim" "GEEN_B" 
rsync -avH --info=progress2 "$initramfs" "$root_amount"
rm -f $root_bmount/sbin/init
rm -f $root_amount/bin/init
cp ../root-a/sbin/init $root_amount/sbin/init
cp ../root-b/sbin/init $root_bmount/sbin/init
chmod +x $root_amount/sbin/init
chmod +x $root_bmount/sbin/init
echo_c "Unmounting..." "GEEN_B"
umount $root_amount
umount $root_amount -l
umount $root_bmount
umount $root_bmount -l
losetup -D
echo_c "Done!" "GEEN_B"