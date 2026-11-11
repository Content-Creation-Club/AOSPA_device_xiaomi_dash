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

.PHONY: dash-strict-kernel
dash-strict-kernel: PRIVATE_KERNEL_BUILD_SCRIPT := $(LOCAL_PATH)/build-kleaf.sh
dash-strict-kernel:
	$(hide) bash $(PRIVATE_KERNEL_BUILD_SCRIPT) \
	    --//build/kernel/kleaf:kmi_symbol_list_violations_check=true \
	    //kernel_device_modules-6.6:kernel_strict.user \
	    //kernel_device_modules-6.6:ufs_wlun_bootstrap_strict.user

.PHONY: ufs-wlun-bootstrap
ufs-wlun-bootstrap: PRIVATE_KERNEL_BUILD_SCRIPT := $(LOCAL_PATH)/build-kleaf.sh
ufs-wlun-bootstrap:
	$(hide) bash $(PRIVATE_KERNEL_BUILD_SCRIPT) \
	    --//build/kernel/kleaf:kmi_symbol_list_violations_check=true \
	    //kernel_device_modules-6.6:ufs_wlun_bootstrap_strict.user

# PA skips kernel compilation rules when a prebuilt Image is selected.
$(eval $(call copy-one-file,$(TARGET_PREBUILT_KERNEL),$(PRODUCT_OUT)/kernel))

# Platform contains only first-stage inputs; Soong installs kernel modules.
dash_platform_root := $(DASH_KERNEL_INPUTS)/platform
dash_platform_files := first_stage_ramdisk/fstab.mt6991
dash_platform_outputs := $(addprefix $(TARGET_VENDOR_RAMDISK_OUT)/,$(dash_platform_files))
dash_fstab_filter := kernel/xiaomi/dash/kernel_device_modules-6.6/kernel/boot-compat/fstab-no-avb.awk
$(dash_platform_outputs): PRIVATE_FSTAB_FILTER := $(dash_fstab_filter)
$(dash_platform_outputs): $(dash_platform_root)/first_stage_ramdisk/fstab.mt6991 $(dash_fstab_filter)
	$(hide) mkdir -p $(dir $@)
	$(hide) awk -f $(PRIVATE_FSTAB_FILTER) $< > $@
ALL_DEFAULT_INSTALLED_MODULES += $(dash_platform_outputs)

ifdef BUILDING_VBMETA_IMAGE
$(PRODUCT_OUT)/vbmeta.img: $(DASH_STOCK_INPUTS)/vbmeta_vendor.img
endif
endif
