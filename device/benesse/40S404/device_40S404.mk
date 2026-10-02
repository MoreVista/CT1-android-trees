LOCAL_PATH := device/benesse/40S404

$(call inherit-product, vendor/benesse/40S404/40S404-vendor.mk)

PRODUCT_AAPT_CONFIG := normal
TARGET_SCREEN_WIDTH := 1024
TARGET_SCREEN_HEIGHT := 768
DEVICE_RESOLUTION := 1024x768

# File names are keyed to ro.hardware (= "freescale" from the kernel cmdline's
# androidboot.hardware), NOT the product name -- init only imports
# init.${ro.hardware}.rc and ueventd.${ro.hardware}.rc. init.usb.rc and
# init.trace.rc are imported by init.rc but are not placed in the ramdisk
# by this product chain, so copy them from system/core/rootdir explicitly.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.freescale.rc:root/init.freescale.rc \
    $(LOCAL_PATH)/init.freescale.usb.rc:root/init.freescale.usb.rc \
    $(LOCAL_PATH)/ueventd.freescale.rc:root/ueventd.freescale.rc \
    $(LOCAL_PATH)/fstab.freescale:root/fstab.freescale \
    system/core/rootdir/init.usb.rc:root/init.usb.rc \
    system/core/rootdir/init.trace.rc:root/init.trace.rc

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
