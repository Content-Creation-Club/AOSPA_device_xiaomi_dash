#!/bin/bash
# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0
set -eu
hooks_baseline=ce690697d1f6d60ddf2785374432fa812e0c7c7b
activity_baseline=adced679019b20628cebd485eeaa46f129da344b
hooks_patch=device/xiaomi/dash/power/patches/frameworks-base.patch
mkdir -p device/xiaomi/dash/power/patches
git -C frameworks/base diff "$hooks_baseline" -- \
    services/proguard.flags \
    services/core/java/com/android/server/power/DevicePowerManagerInternal.java \
    services/core/java/com/android/server/power/PowerManagerService.java \
    services/core/java/com/android/server/wm/DisplayPolicy.java \
    > "$hooks_patch"
hooks_interface=services/core/java/com/android/server/power/DevicePowerManagerInternal.java
if ! git -C frameworks/base ls-files --error-unmatch "$hooks_interface" >/dev/null 2>&1; then
    git -C frameworks/base diff --no-index -- /dev/null "$hooks_interface" >> "$hooks_patch" \
        || test "$?" = 1
fi

# Lifecycle notifications are based on this ROM's WM revision, independent of older power hooks.
git -C frameworks/base diff "$activity_baseline" -- \
    services/core/java/com/android/server/wm/ActivityRecord.java \
    services/core/java/com/android/server/wm/ActivityTaskManagerInternal.java \
    services/core/java/com/android/server/wm/ActivityTaskManagerService.java \
    >> "$hooks_patch"
