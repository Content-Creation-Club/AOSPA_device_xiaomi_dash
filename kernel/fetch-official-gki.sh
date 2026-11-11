#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

workspace=$(readlink -f kernel/xiaomi/dash)
device_dir=$(cd "$(dirname "$0")"; pwd)
tag=android15-6.6-2026-10_r3
build=16867777
cache="$workspace/out/bazel/repositories/dash_official_gki/$tag"
base="https://ci.android.com/builds/submitted/$build/kernel_aarch64/latest/raw"
mkdir -p "$cache"

fetch() {
    local name=$1 url=$2
    if [[ ! -s "$cache/$name" ]]; then
        curl --fail --location --connect-timeout 15 --max-time 180 \
            --continue-at - --output "$cache/$name.part" "$url"
        mv "$cache/$name.part" "$cache/$name"
    fi
}

for name in Image.lz4 vmlinux.symvers abi_symbollist.raw System.map \
            gki-info.txt system_dlkm.flatten.erofs.img; do
    fetch "$name" "$base/$name"
done

if [[ ! -s "$cache/.config" ]]; then
    "$workspace/kernel-6.6/scripts/extract-ikconfig" "$cache/Image.lz4" > "$cache/.config"
fi

need_modules=false
while read -r name; do
    if [[ "$name" != tls.ko && ! -s "$cache/$name" ]]; then
        need_modules=true
    fi
done < "$device_dir/modules.load.system_dlkm"
if $need_modules; then
    mkdir -p "$cache/system_dlkm"
    fsck.erofs --extract="$cache/system_dlkm" "$cache/system_dlkm.flatten.erofs.img"
    while IFS= read -r -d '' module; do
        mv "$module" "$cache/$(basename "$module")"
    done < <(find "$cache/system_dlkm" -name '*.ko' -type f -print0)
fi

# Official GKI does not build TLS. Keep the explicitly audited local module;
# its signature is not trusted by the official core, so it must obey vendor KMI.
if [[ ! -s "$cache/tls.ko" ]]; then
    cp "$workspace/bazel-bin/kernel_device_modules-6.6/kernel_strict.user/tls.ko" "$cache/tls.ko"
fi

printf 'Official GKI inputs: %s (CI %s)\n' "$cache" "$build"
