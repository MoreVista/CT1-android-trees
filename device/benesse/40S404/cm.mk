# AOSP base package set. Without this, none of the core native/system
# packages are part of the product (servicemanager, surfaceflinger, installd,
# vold, linker via core.mk/base.mk, SystemUI, Settings, ...): the build
# "succeeds" but yields a /system with only ~150 binaries and no
# /system/bin/linker, so init cannot even exec /system/bin/sh. vendor/cm
# does not inherit these itself. generic_no_telephony.mk (not full_base.mk)
# is used on purpose: full_base.mk also pulls in emulator.mk, which drags in
# the SDK emulator/qemu packages this tree has had stripped out.
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/locales_full.mk)
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)

$(call inherit-product, vendor/cm/config/common_full_tablet_wifionly.mk)
$(call inherit-product, device/benesse/40S404/device_40S404.mk)

PRODUCT_DEVICE := 40S404
PRODUCT_NAME := cm_40S404
PRODUCT_BRAND := benesse
PRODUCT_MODEL := 40S404
PRODUCT_MANUFACTURER := PANASONIC

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.build.product=40S404 \
    ro.product.device=40S404 \
    ro.product.board=SABRESD \
    ro.board.platform=imx6
