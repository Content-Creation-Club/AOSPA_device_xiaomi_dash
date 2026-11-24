# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/xiaomi/dash

# Shared hardware implementation.
DASH_HARDWARE_PATH ?= hardware/xiaomi/dash
$(call inherit-product, $(DASH_HARDWARE_PATH)/dash.mk)
$(call inherit-product, $(DASH_HARDWARE_PATH)/kernel/device.mk)
$(call inherit-product, $(DASH_HARDWARE_PATH)/boot/device.mk)

# DisplayFeature V2 must precede both system_server clients for dexpreopt.
PRODUCT_PACKAGES += dash-displayfeature
PRODUCT_SYSTEM_SERVER_JARS_EXTRA += system_ext:dash-displayfeature

# Device features
$(call inherit-product, $(DEVICE_PATH)/fod/fod.mk)
$(call inherit-product, $(DEVICE_PATH)/display/brightness/brightness.mk)
$(call inherit-product, $(DASH_HARDWARE_PATH)/power/power.mk)
$(call inherit-product, $(DASH_HARDWARE_PATH)/ims/ims.mk)
$(call inherit-product, $(DASH_HARDWARE_PATH)/esim/esim.mk)

# PA's eSIM profile assistant.
PRODUCT_PACKAGES += OpenEUICC

# Product additions
$(call inherit-product-if-exists, vendor/xiaomi/dash-miuicamera/miuicamera.mk)

# Dynamic-partition device.
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# Virtual A/B. The retained stock vendor supplies the runtime VABC properties.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)

PRODUCT_PACKAGES += \
    snapuserd_ramdisk \
    update_engine \
    update_verifier

# A performance flagship powered by a nerfed previous-gen MTK flagship SoC.
PRODUCT_SHIPPING_API_LEVEL := 36
PRODUCT_TARGET_VNDK_VERSION := 35

# Retain the stock vendor-side images.
PRODUCT_BUILD_DTBO_IMAGE := false
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := false
PRODUCT_BUILD_DEBUG_VENDOR_BOOT_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_ODM_DLKM_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := false

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    $(DEVICE_PATH)/framework_compatibility_matrix.xml

PRODUCT_SOONG_NAMESPACES += \
    vendor/xiaomi/dash

# Properties
$(call inherit-product, $(DEVICE_PATH)/configs/properties.mk)

# Display
PRODUCT_PACKAGES += \
    DashRefreshRate \
    dash-eyecare \
    dash-displayfeature-compat
PRODUCT_SYSTEM_SERVER_JARS_EXTRA += system_ext:dash-eyecare

# Init
PRODUCT_PACKAGES += \
    init.dash-system_ext.rc

# HIDL compatibility
PRODUCT_PACKAGES += \
    android.hidl.allocator@1.0-service \
    libhidltransport

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay

PRODUCT_PACKAGES += \
    DashFrameworkResOverlay \
    DashStatusBarHeightOverlay \
    PinnerOverlay \
    DashSettingsOverlay \
    DashSettingsProviderOverlay \
    DashPocoGlobalSettingsProviderOverlay \
    DashPocoIndiaSettingsProviderOverlay \
    DashSystemUIOverlay \
    DashTelecommOverlay \
    DashTelephonyOverlay \
    DashWifiOverlay
