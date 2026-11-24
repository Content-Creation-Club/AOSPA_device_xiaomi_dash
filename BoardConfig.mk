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

DASH_HARDWARE_PATH ?= hardware/xiaomi/dash
DASH_KERNEL_WORKSPACE := kernel/xiaomi/dash
include $(DASH_HARDWARE_PATH)/kernel/BoardConfig.mk
include $(DASH_HARDWARE_PATH)/boot/BoardConfig.mk

ifneq ($(wildcard vendor/lineage-priv/keys/avb.pk8),)
BOARD_AVB_KEY_PATH := vendor/lineage-priv/keys/avb.pk8
BOARD_AVB_ALGORITHM := SHA256_RSA4096
endif

TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(PRODUCT_OUT)/kernel
TARGET_KERNEL_SOURCE := $(DASH_KERNEL_WORKSPACE)/kernel-6.6
TARGET_KERNEL_CONFIG := gki_defconfig

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

# Partial OTA includes the ROM images and the stock boot logo.
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    logo \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vendor_boot \
    vendor_dlkm
BOARD_PARTIAL_OTA_UPDATE_PARTITIONS_LIST := $(AB_OTA_PARTITIONS)
BOARD_PACK_RADIOIMAGES += logo

# Match the stock OS4 main group without generating a replacement super image.
BOARD_SUPER_PARTITION_METADATA_DEVICE := super
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 12874416128
BOARD_MAIN_PARTITION_LIST := product system system_dlkm system_ext vendor_dlkm

TARGET_USERIMAGES_USE_F2FS := true

# Choose a preferred file system.
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

# I don't modify /vendor.
TARGET_USES_PREBUILT_VENDOR_SEPOLICY := true
# PA's replacement-vendor policy is not shipped with the retained stock vendor.
BOARD_VENDOR_SEPOLICY_DIRS := $(filter-out vendor/aospa/sepolicy/vendor,$(BOARD_VENDOR_SEPOLICY_DIRS))

include $(DASH_HARDWARE_PATH)/BoardConfig.mk

BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/system_ext/private

include $(DEVICE_PATH)/power/BoardConfig.mk
include $(DEVICE_PATH)/fod/BoardConfig.mk
include $(DASH_HARDWARE_PATH)/ims/BoardConfig.mk
include $(DASH_HARDWARE_PATH)/esim/BoardConfig.mk

# BoardConfig is loaded separately from product inheritance.
include $(DEVICE_PATH)/health/BoardConfig.mk
