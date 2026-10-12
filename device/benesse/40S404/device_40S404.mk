LOCAL_PATH := device/benesse/40S404

$(call inherit-product, vendor/benesse/40S404/40S404-vendor.mk)

DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay

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
    $(LOCAL_PATH)/wifi_load.sh:system/bin/wifi_load.sh \
    $(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
    $(LOCAL_PATH)/audio_init.sh:system/bin/audio_init.sh \
    $(LOCAL_PATH)/idc/rohm_bu21025.idc:system/usr/idc/rohm_bu21025.idc


# Hardware feature declarations (stock shipped these; without android.hardware.wifi
# Settings hides the Wi-Fi entry entirely).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/40s404_core_hardware.xml:system/etc/permissions/40s404_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:system/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.location.xml:system/etc/permissions/android.hardware.location.xml

PRODUCT_PACKAGES += \
    wpa_supplicant \
    wpa_supplicant.conf \
    dhcpcd.conf \
    hostapd \
    libwpa_client \
    hostapd_cli \
    wpa_cli

# On-screen navigation bar (the tablet has hardware keys too, but they are few and
# not labelled); persist.sys.fsl.hwrender=1 renders VPU-decoded video straight into
# native window buffers (set 0 to fall back to CPU colour conversion).
# ro.zygote.disable_gl_preload: zygote preloading GL (libGAL gcoSURF_Construct) SIGSEGVs on
# the stock Vivante blobs under KitKat.
PRODUCT_PROPERTY_OVERRIDES += \
    qemu.hw.mainkeys=0 \
    persist.sys.fsl.hwrender=1 \
    ro.zygote.disable_gl_preload=true

# NOTE: build as cm_40S404-userdebug: eng forces ro.kernel.android.checkjni=1 (build/core/main.mk),
# CheckJNI verifies every JNI call and is very slow on a Cortex-A9.

# Dalvik heap sizing (values from the stock build.prop). Without these the VM
# falls back to a 16 MB per-app heap and apps such as SkyTube die with OOM.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=64m \
    dalvik.vm.heapsize=384m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=15 \
    ro.carrier=wifi-only \
    ro.opengles.version=131072

# Personal dev tablet: skip the adb RSA authorisation dialog (userdebug defaults to secure).
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=0

# WebView: no prebuilt chromium-webview repos in this tree (they fail to sync), use the prebuilt
# WebViewGoogle APK shared with the TAB-A03 port.
PRODUCT_PACKAGES += \
    WebViewGoogle \
    libwebviewchromium_loader \
    libwebviewchromium_plat_support
