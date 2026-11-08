# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),dash)

# Build explicitly before image packaging so Ninja observes the updated shared
# module inputs in the packaging invocation. Kati must not own cache outputs
# reached through a source-tree symlink.
.PHONY: kernel
kernel: PRIVATE_KERNEL_BUILD_SCRIPT := $(LOCAL_PATH)/build-kleaf.sh
kernel:
	@echo "Kleaf: dash shared kernel and modules"
	$(hide) bash $(PRIVATE_KERNEL_BUILD_SCRIPT)
	$(hide) mkdir -p $(PRODUCT_OUT)
	$(hide) if ! cmp -s $(TARGET_PREBUILT_KERNEL) $(PRODUCT_OUT)/kernel; then cp -f $(TARGET_PREBUILT_KERNEL) $(PRODUCT_OUT)/kernel; fi

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
