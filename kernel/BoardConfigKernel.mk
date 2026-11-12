# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

include $(DEVICE_PATH)/kernel/profile.mk
$(call soong_config_set,kleaf,profile,$(DASH_KERNEL_PROFILE))
$(call soong_config_set_bool,kleaf,system_dlkm,$(DASH_SYSTEM_DLKM))
$(foreach partition,vendor_ramdisk vendor_dlkm,$(call soong_config_set,kleaf,$(partition)_modules,$(strip $(file <$(DEVICE_PATH)/kernel/modules.$(partition)))))
$(call soong_config_set,kleaf,vendor_ramdisk_load,$(strip $(file <$(DEVICE_PATH)/kernel/modules.load.platform)))
$(call soong_config_set,kleaf,vendor_dlkm_load,$(strip $(file <$(DEVICE_PATH)/kernel/modules.load.vendor_dlkm)))
$(call soong_config_set,kleaf,system_dlkm_modules,$(strip $(file <$(DEVICE_PATH)/kernel/modules.load.system_dlkm)))
$(call soong_config_set,kleaf,system_dlkm_load,$(SOONG_CONFIG_kleaf_system_dlkm_modules))
DASH_KERNEL_INPUTS := vendor/xiaomi/dash/kernel-inputs
DASH_STOCK_INPUTS := vendor/xiaomi/dash/stock-305

# Kleaf owns its retained cache and Bazel symlinks in the shared workspace.
BUILD_BROKEN_SRC_DIR_RW_ALLOWLIST += $(realpath kernel/xiaomi/dash)

TARGET_NO_KERNEL := false
TARGET_KERNEL_SOURCE := kernel/xiaomi/dash/kernel-6.6
TARGET_KERNEL_CONFIG := gki_defconfig
TARGET_KERNEL_VERSION := 6.6
# Soong owns the kernel; bypass legacy ROM Make builders.
TARGET_NO_KERNEL_OVERRIDE := true
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(PRODUCT_OUT)/kernel
BOARD_KERNEL_IMAGE_NAME := Image.lz4

BOARD_USES_GENERIC_KERNEL_IMAGE := true
# Includes ACK ASB-2026-10-05_15-6.6
BOOT_SECURITY_PATCH := 2026-10-01
# Follows the system independently.
INIT_BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOARD_BOOT_HEADER_VERSION := 4
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
# Leave room for the retained OrangeFox fragment in the 64 MiB vendor_boot.
BOARD_RAMDISK_USE_LZ4 := false
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(DASH_KERNEL_INPUTS)
BOARD_MKBOOTIMG_ARGS += --header_version 4 --kernel_offset 0x80000000
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset 0xa6f00000 --tags_offset 0x87c80000
BOARD_MKBOOTIMG_ARGS += --dtb_offset 0x87c80000
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# Keep the existing recovery in vendor_boot without rebuilding it.
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_VENDOR_RAMDISK_FRAGMENT.recovery.PREBUILT := $(DASH_KERNEL_INPUTS)/recovery.cpio.gz

BOARD_USES_VENDOR_DLKMIMAGE := true
# Kleaf strips distribution modules before signing. Keep GKI signatures.
BOARD_DO_NOT_STRIP_VENDOR_RAMDISK_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
ifeq ($(DASH_SYSTEM_DLKM),true)
include $(DEVICE_PATH)/kernel/system-dlkm.mk
endif

# Build only the top-level vbmeta from current image descriptors.
# Vendor stays on stock 305; retain its descriptor without rebuilding it.
# Keep AVB metadata discovery and disable hashtree verification only.
BOARD_AVB_ENABLE := true
BOARD_AVB_KEY_PATH := vendor/lineage-priv/keys/avb.pk8
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 1
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --include_descriptors_from_image $(DASH_STOCK_INPUTS)/vbmeta_vendor.img
