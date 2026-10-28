# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/xiaomi/dash

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic
TARGET_SUPPORTS_32_BIT_APPS := false
TARGET_SUPPORTS_64_BIT_APPS := true

# Platform identity
TARGET_BOARD_PLATFORM := mt6991
TARGET_BOOTLOADER_BOARD_NAME := mt6991
TARGET_NO_BOOTLOADER := true

# Kleaf builds the kernel; Android assembles the partition images.
include $(DEVICE_PATH)/kernel/BoardConfigKernel.mk

BOARD_KERNEL_PAGESIZE := 4096
BOARD_FLASH_BLOCK_SIZE := 262144

TARGET_SCREEN_DENSITY := 480

# Framework partition filesystems.
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_USES_METADATA_PARTITION := true

TARGET_USERIMAGES_USE_F2FS := true

# Choose a preferred file system.
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

# I don't modify /vendor.
TARGET_USES_PREBUILT_VENDOR_SEPOLICY := true

# Keep vendor_dlkm within the stock partition size.
BOARD_VENDOR_DLKMIMAGE_PARTITION_SIZE := 25477120
BOARD_VENDOR_DLKMIMAGE_EROFS_COMPRESSOR := lz4hc,level=12
BOARD_VENDOR_DLKMIMAGE_EROFS_PCLUSTER_SIZE := 16384

DASH_HARDWARE_PATH ?= hardware/xiaomi/dash
include $(DASH_HARDWARE_PATH)/BoardConfig.mk

BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/system_ext/private

include $(DEVICE_PATH)/display/brightness/BoardConfig.mk
include $(DEVICE_PATH)/power/BoardConfig.mk
include $(DEVICE_PATH)/fod/BoardConfig.mk
include $(DEVICE_PATH)/ims/BoardConfig.mk

# BoardConfig is loaded separately from product inheritance.
include $(DEVICE_PATH)/health/BoardConfig.mk
