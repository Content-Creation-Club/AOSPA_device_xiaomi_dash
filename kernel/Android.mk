# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),dash)

# PA skips kernel compilation rules when a prebuilt Image is selected.
$(eval $(call copy-one-file,$(TARGET_PREBUILT_KERNEL),$(PRODUCT_OUT)/kernel))

# Platform contains only first-stage inputs; Soong installs kernel modules.
dash_platform_root := $(DASH_KERNEL_INPUTS)/platform
dash_platform_files := first_stage_ramdisk/fstab.mt6991
dash_platform_outputs := $(addprefix $(TARGET_VENDOR_RAMDISK_OUT)/,$(dash_platform_files))
$(foreach file,$(dash_platform_files),$(eval $(call copy-one-file,$(dash_platform_root)/$(file),$(TARGET_VENDOR_RAMDISK_OUT)/$(file))))
ALL_DEFAULT_INSTALLED_MODULES += $(dash_platform_outputs)

ifdef BUILDING_VBMETA_IMAGE
$(PRODUCT_OUT)/vbmeta.img: $(DASH_STOCK_INPUTS)/vbmeta_vendor.img
endif
endif
