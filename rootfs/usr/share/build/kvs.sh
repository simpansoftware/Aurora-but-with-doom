#!/bin/bash

apk add git curl build-base linux-headers partx bash coreutils e2fsprogs e2fsprogs-extra util-linux sgdisk gptfdisk parted file grep sed findutils
curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env
git clone https://github.com/kxtzownsu/kvs.git
cd kvs && make