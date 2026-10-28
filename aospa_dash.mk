# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

PRODUCT_NAME := aospa_dash
PRODUCT_DEVICE := dash
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 2602BRT18C
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Framework partition identity.
PRODUCT_SYSTEM_NAME := dash
PRODUCT_SYSTEM_DEVICE := dash
PRODUCT_SYSTEM_BRAND := Redmi
PRODUCT_SYSTEM_MODEL := 2602BRT18C
PRODUCT_SYSTEM_MANUFACTURER := Xiaomi

PRODUCT_RELEASE_NAME := dash
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS :=
TARGET_BOARD_PLATFORM := mt6991

# 64-bit-only
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
$(call inherit-product, device/xiaomi/dash/device.mk)
$(call inherit-product, device/xiaomi/dash/health/health.mk)

# NO APERTURE.
PRODUCT_NO_CAMERA := true

$(call inherit-product, device/xiaomi/dash/aospa/aospa-target.mk)
