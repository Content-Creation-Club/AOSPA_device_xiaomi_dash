# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Lineage charging control.
PRODUCT_PACKAGES += \
    dash-fast-charge \
    dash-health
DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/health/overlay
