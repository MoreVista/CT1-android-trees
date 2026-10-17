# Build /system/xbin/su (Settings -> Developer options -> Root access gates it) for debugging.
WITH_SU := true

# AOSP base package set (as the TAB-A03 LOS 14.1 port does).
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

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
