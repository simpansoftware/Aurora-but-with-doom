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

shim="$1"

source ./utils/functions.sh

initramfs=$(realpath -m "./initramfs")
rootfs=$(realpath -m "./rootfs")
buildrootfs=$(realpath -m "./buildrootfs")

rm -rf "${rootfs}" 
mkdir -p "${rootfs}"

if findmnt -T "$rootfs" -o OPTIONS -n | grep -qE 'noexec|nodev'; then
    mount -o remount,dev,exec "$(findmnt -T "$rootfs" -o TARGET -n)"
fi

echo_c "Bootstrapping Alpine" GEEN_B

if [ ! -f alpine-minirootfs.tar.gz ]; then
    curl -L https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/$arch/alpine-minirootfs-3.22.0-$arch.tar.gz -o alpine-minirootfs.tar.gz
fi
tar -xf alpine-minirootfs.tar.gz -C $rootfs
rm -f $rootfs/sbin/init

echo "nameserver 8.8.8.8" > $rootfs/etc/resolv.conf
# haha 69
for arg in "$@"; do
    case "$arg" in
        --nowifi|-nw)
            export NOWIFI=true
            ;;
    esac
done

unmount() {
    for dir in proc sys dev run; do
        umount -l "$rootfs/$dir"
    done
}
trap unmount EXIT
cp -Lar $rootfs/. $initramfs/
cp -r ../initramfs/. $initramfs/
chroot "$initramfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_initramfs_alpine.sh && /opt/setup_initramfs_alpine.sh $arch"
cp -r ../rootfs/. $rootfs/
chroot "$rootfs" /bin/sh -c "export PATH=/sbin:/bin:/usr/sbin:/usr/bin && chmod +x /opt/setup_rootfs_alpine.sh && /opt/setup_rootfs_alpine.sh $arch"

if [ "$NOWIFI" = true ]; then
    echo_c "Flag 'nowifi' set. Skipping firmware download..." YELLOW_B
else
    echo_c "Downloading firmware..." GEEN_B
    git clone --depth=1 https://chromium.googlesource.com/chromiumos/third_party/linux-firmware $rootfs/lib/firmware/
fi

rm -rf $(find $rootfs/lib/firmware/* -not -path "*wifi*")

trap - EXIT
unmount

echo_c "Rootfs Created" GEEN_B
echo_c "Done!" GEEN_B