#
# SPDX-FileCopyrightText: Paranoid Android
# SPDX-License-Identifier: Apache-2.0
#

# Enable support for APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# b/344511668
PRODUCT_PACKAGES += \
    android.software.credentials.prebuilt.xml

# Enable allowlist for some aosp packages that should not be scanned in a "stopped" state
# Some CTS test case failed after enabling feature config_stopSystemPackagesByDefault
PRODUCT_PACKAGES += initial-package-stopped-states-aosp.xml

# Exclude repos from bp scanning
PRODUCT_SOURCE_ROOT_DIRS += -prebuilts/misc/protobuf_vendorcompat \
    -platform_testing/libraries/sdv \
    -platform_testing/tests/sdv \
    -platform_testing/libraries/automotive/display_safety \
    -platform_testing/tests/automotive/display_safety \
    -device/generic/trusty/microdroid \
    -device/qcom \
    -hardware/qcom \
    -vendor/codeaurora \
    -vendor/qcom/common \
    -vendor/qcom/opensource \
    vendor/codeaurora/commonsys/telephony/extphone \
    vendor/codeaurora/commonsys/telephony/internal \
    vendor/codeaurora/commonsys/telephony/qti-utils \
    vendor/qcom/opensource/interfaces/Android.bp \
    vendor/qcom/opensource/interfaces/bluetooth_audio \
    vendor/qcom/opensource/interfaces/servicetracker \
    vendor/qcom/opensource/interfaces/appLauncherService \
    vendor/qcom/opensource/interfaces/wifi \
    vendor/qcom/opensource/interfaces/camera/device/1.0 \
    vendor/qcom/opensource/core-utils/appLauncherServiceImpl \
    vendor/qcom/opensource/commonsys/android-feature-config/qcomfeatureconfig \
    vendor/qcom/opensource/commonsys-intf/display/Android.bp

# Abstruct
PRODUCT_PACKAGES += \
    Abstruct

# AOSPA Version.
$(call inherit-product, vendor/aospa/target/product/version.mk)

# AOSPA private configuration - optional.
$(call inherit-product-if-exists, vendor/aospa-priv/target/product/aospa-priv-target.mk)

# APNs
ifneq ($(TARGET_NO_TELEPHONY), true)
PRODUCT_COPY_FILES += \
    vendor/aospa/target/config/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml
endif

# Audio
# Increase volume level steps
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.media_vol_steps=30

# Boot Animation
$(call inherit-product, vendor/aospa/bootanimation/bootanimation.mk)

# Camera
ifneq ($(PRODUCT_NO_CAMERA),true)
PRODUCT_PACKAGES += \
    Aperture
endif

# curl
PRODUCT_PACKAGES += \
    curl

# Dex2oat
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    dalvik.vm.dex2oat64.enabled=true

# Dexpreopt
# Don't dexpreopt prebuilts. (For GMS).
DONT_DEXPREOPT_PREBUILTS := true

PRODUCT_DEXPREOPT_SPEED_APPS += \
    Launcher3QuickStep \
    ParanoidSystemUI

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.systemuicompilerfilter=speed

# Display
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    debug.sf.frame_rate_multiple_threshold=60 \
    ro.surface_flinger.enable_frame_rate_override=false

# EGL - Blobcache configuration
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.egl.blobcache.multifile=true \
    ro.egl.blobcache.multifile_limit=33554432

# Exfat FS
PRODUCT_PACKAGES += \
    fsck.exfat \
    mkfs.exfat

# Fonts
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/aospa/fonts/,$(TARGET_COPY_OUT_PRODUCT)/fonts) \
    vendor/aospa/target/config/fonts_customization.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/fonts_customization.xml

# Gestures
PRODUCT_PACKAGES += \
    vendor.aospa.power-service

# Google - GMS, Pixel, and Mainline Modules
$(call inherit-product, vendor/google/gms/config.mk)
$(call inherit-product, vendor/google/pixel/config.mk)
ifneq ($(TARGET_EXCLUDE_GMODULES), true)
$(call inherit-product-if-exists, vendor/google/modules/build/mainline_modules.mk)
endif

PRODUCT_PRODUCT_PROPERTIES += \
    remote_provisioning.enable_rkpd=true \
    remote_provisioning.hostname=remoteprovisioning.googleapis.com

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
     vendor/aospa/target/config/aospa_vendor_framework_compatibility_matrix.xml

PRODUCT_PACKAGES += \
    android.hidl.base@1.0 \
    android.hidl.manager@1.0 \
    android.hidl.base@1.0.vendor \
    android.hidl.manager@1.0.vendor

# Java Optimizations
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# MTE
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.system_server=off

# One Handed Mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Overlays
PRODUCT_PACKAGES += DashWakeGestureOverlay

$(call inherit-product, vendor/aospa/overlay/overlays.mk)

# Overlays (Translations)
$(call inherit-product-if-exists, vendor/aospa/translations/translations.mk)

# Paranoid Packages
PRODUCT_PACKAGES += \
    ParanoidPapers \
    ParanoidSystemUI

# Paranoid Hub (OTA)
ifneq ($(filter STABLE BETA,$(AOSPA_BUILDTYPE)),)
PRODUCT_PACKAGES += ParanoidHub
endif

# Paranoid Sense
PRODUCT_PACKAGES += \
    ParanoidSense

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml

# Enable Sense service for 64-bit only
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

# Permissions
PRODUCT_COPY_FILES += \
    vendor/aospa/target/config/permissions/default_permissions_com.google.android.deskclock.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default_permissions_com.google.android.deskclock.xml \
    vendor/aospa/target/config/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml \
    vendor/aospa/target/config/permissions/org.lineageos.health.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.health.xml

# Preinstalled Packages
PRODUCT_COPY_FILES += \
    vendor/aospa/target/config/preinstalled-packages-aospa.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-aospa.xml

# Privapp-permissions
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.control_privapp_permissions?=log

# Rescue Party
# Disable RescueParty due to high risk of data loss
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.disable_rescue=true

# Sensitive Phone Numbers
ifneq ($(TARGET_NO_TELEPHONY), true)
PRODUCT_COPY_FILES += \
    vendor/aospa/target/config/sensitive_pn.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sensitive_pn.xml
endif

# Sensors
PRODUCT_PACKAGES += \
    android.frameworks.sensorservice@1.0.vendor

# StrictMode
ifneq ($(TARGET_BUILD_VARIANT),eng)
# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.strictmode.disable=true
endif

# SEPolicy
$(call inherit-product, vendor/aospa/sepolicy/sepolicy.mk)

# Telephony - PA framework dependencies and AOSP
ifneq ($(TARGET_NO_TELEPHONY), true)
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext \
    Stk

PRODUCT_BOOT_JARS += telephony-ext
endif

# TextClassifier
PRODUCT_PACKAGES += \
    libtextclassifier_annotator_en_model \
    libtextclassifier_annotator_universal_model \
    libtextclassifier_actions_suggestions_universal_model \
    libtextclassifier_lang_id_model

# Theme Picker
PRODUCT_PACKAGES += \
    ThemePicker

# WiFi
PRODUCT_PACKAGES += \
    libwpa_client

PRODUCT_VENDOR_MOVE_ENABLED := true
