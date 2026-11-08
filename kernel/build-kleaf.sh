#!/bin/bash
# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

workspace=$(readlink -f kernel/xiaomi/dash)
bin=$(readlink "$workspace/bazel-bin")
output_base=${bin%/execroot/*}
if [[ "$output_base" == "$bin" || ! -d "$output_base/action_cache" ]]; then
    echo "dash: existing Kleaf output base not found via bazel-bin" >&2
    exit 1
fi

# Pin the existing output base: moving the workspace must not select a new cache.
cd "$workspace"
export PROJECT=mgk_64_k66 MODE=user DEFCONFIG_OVERLAYS=dash.config
export KERNEL_VERSION=kernel-6.6
export KLEAF_USE_KLEAF_LOCALVERSION=true
export KLEAF_EXTRA_GIT_PROJECTS=kernel-6.6:kernel_device_modules-6.6
exec prebuilts/kernel-build-tools/bazel/linux-x86_64/bazel \
    --output_user_root="${output_base%/*}" \
    --output_base="$output_base" \
    --bazelrc=build/kernel/kleaf/common.bazelrc \
    --bazelrc=build/kernel/kleaf/bazelrc/stamp.bazelrc \
    build --noenable_bzlmod --experimental_writable_outputs \
    --config=stamp \
    --workspace_status_command=build/kernel/kleaf/workspace_status.sh \
    --jobs="${UNI_KERNEL_JOBS:-8}" \
    --//build/kernel/kleaf:kmi_symbol_list_violations_check=false \
    --//build/bazel_mgk_rules:kernel_version=6.6 \
    //kernel_device_modules-6.6:mgk_64_k66_kernel_aarch64.user \
    //kernel_device_modules-6.6:mgk_64_k66_customer_modules_install.user \
    //kernel_device_modules-6.6:mgk_64_k66_merged_uapi_headers.user \
    //kernel_device_modules-6.6:dash_stock305_heap_refill.user \
    //kernel_device_modules-6.6:dash_stock305_disp_sec.user
