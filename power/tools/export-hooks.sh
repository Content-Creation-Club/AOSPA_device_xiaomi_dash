#!/bin/bash
# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
hooks_baseline=adced679019b20628cebd485eeaa46f129da344b
hooks_patch=device/xiaomi/dash/power/patches/frameworks-base.patch
mkdir -p tmp device/xiaomi/dash/power/patches
hooks_tmp=$(mktemp tmp/dash-power-hooks.XXXXXX)
trap 'rm -f "$hooks_tmp"' EXIT

printf '# dash power and resumed-activity framework hooks\n# Base: %s\n\n' \
    "$hooks_baseline" > "$hooks_tmp"
git -C frameworks/base diff "$hooks_baseline" -- \
    services/core/java/com/android/server/power/DevicePowerManagerInternal.java \
    services/core/java/com/android/server/power/PowerManagerService.java \
    services/core/java/com/android/server/wm/DisplayPolicy.java \
    services/core/java/com/android/server/wm/ActivityRecord.java \
    services/core/java/com/android/server/wm/ActivityTaskManagerInternal.java \
    services/core/java/com/android/server/wm/ActivityTaskManagerService.java \
    >> "$hooks_tmp"
hooks_interface=services/core/java/com/android/server/power/DevicePowerManagerInternal.java
if ! git -C frameworks/base ls-files --error-unmatch "$hooks_interface" >/dev/null 2>&1; then
    git -C frameworks/base diff --no-index -- /dev/null "$hooks_interface" >> "$hooks_tmp" \
        || test "$?" = 1
fi

# Export only the power/WM ProGuard hunks from this shared file.
git -C frameworks/base diff "$hooks_baseline" -- services/proguard.flags | python3 -c '
import re
import sys
parts = re.split(r"(?=^@@ )", sys.stdin.read(), flags=re.MULTILINE)
hunks = [h for h in parts[1:]
         if "DevicePowerManagerInternal" in h or "ResumedActivityListener" in h]
if hunks:
    header = re.sub(r"^index .*\n", "", parts[0], flags=re.MULTILINE)
    sys.stdout.write(header + "".join(hunks))
' >> "$hooks_tmp"

chmod 644 "$hooks_tmp"
mv -f "$hooks_tmp" "$hooks_patch"
