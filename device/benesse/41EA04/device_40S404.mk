LOCAL_PATH := device/benesse/40S404

$(call inherit-product, vendor/benesse/40S404/40S404-vendor.mk)

PRODUCT_AAPT_CONFIG := normal
TARGET_SCREEN_WIDTH := 1024
TARGET_SCREEN_HEIGHT := 768
DEVICE_RESOLUTION := 1024x768

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.40S404.rc:root/init.40S404.rc \
    $(LOCAL_PATH)/ueventd.40S404.rc:root/ueventd.40S404.rc \
    $(LOCAL_PATH)/fstab.freescale:root/fstab.freescale \
    $(LOCAL_PATH)/configs/egl.cfg:system/lib/egl/egl.cfg

PRODUCT_PACKAGES += \
    Launcher2 \
    wpa_supplicant \
    wpa_supplicant.conf \
    dhcpcd.conf \
    hostapd \
    wifi_tether \
    libwpa_client \
    hostapd_cli \
    wpa_cli

PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=15 \
    ro.carrier=wifi-only \
    ro.opengles.version=131072
