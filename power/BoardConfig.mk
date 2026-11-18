# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

include $(DASH_HARDWARE_PATH)/power/BoardConfig.mk

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/power/sepolicy/system_ext/private
