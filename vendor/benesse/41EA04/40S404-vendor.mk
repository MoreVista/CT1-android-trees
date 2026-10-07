LOCAL_PATH := vendor/benesse/40S404

# The generic audio HALs (policy/a2dp/usb/r_submix) are NOT taken from the 4.2 stock system:
# KitKat's AudioFlinger is not ABI compatible with them. They are built from source.

$(call inherit-product, vendor/benesse/40S404/40S404-omx.mk)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/proprietary/lib/libGAL.so:system/lib/libGAL.so \
    $(LOCAL_PATH)/proprietary/lib/libGLSLC.so:system/lib/libGLSLC.so \
    $(LOCAL_PATH)/proprietary/lib/libg2d.so:system/lib/libg2d.so \
    $(LOCAL_PATH)/proprietary/lib/libtinyfsl.so:system/lib/libtinyfsl.so \
    $(LOCAL_PATH)/proprietary/egl/libEGL_VIVANTE.so:system/lib/egl/libEGL_VIVANTE.so \
    $(LOCAL_PATH)/proprietary/egl/libGLESv1_CM_VIVANTE.so:system/lib/egl/libGLESv1_CM_VIVANTE.so \
    $(LOCAL_PATH)/proprietary/egl/libGLESv2_VIVANTE.so:system/lib/egl/libGLESv2_VIVANTE.so \
    $(LOCAL_PATH)/proprietary/egl/egl.cfg:system/lib/egl/egl.cfg \
    $(LOCAL_PATH)/proprietary/hw/audio.primary.imx6.so:system/lib/hw/audio.primary.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/camera.imx6.so:system/lib/hw/camera.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/gralloc.imx6.so:system/lib/hw/gralloc.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/gralloc_viv.imx6.so:system/lib/hw/gralloc_viv.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/hwcomposer.imx6.so:system/lib/hw/hwcomposer.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/hwcomposer_viv.imx6.so:system/lib/hw/hwcomposer_viv.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/lights.imx6.so:system/lib/hw/lights.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/power.imx6.so:system/lib/hw/power.imx6.so \
    $(LOCAL_PATH)/proprietary/hw/sensors.SABRESD.so:system/lib/hw/sensors.SABRESD.so \
    $(LOCAL_PATH)/proprietary/etc/audio_policy.conf:system/etc/audio_policy.conf \
    $(LOCAL_PATH)/proprietary/etc/media_profiles.xml:system/etc/media_profiles.xml \
    $(LOCAL_PATH)/proprietary/etc/wifi/mlan.ko:system/etc/wifi/mlan.ko \
    $(LOCAL_PATH)/proprietary/etc/wifi/sd8787.ko:system/etc/wifi/sd8787.ko \
    $(LOCAL_PATH)/proprietary/etc/wifi/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/proprietary/etc/firmware/mrvl/sd8787_uapsta.bin:system/etc/firmware/mrvl/sd8787_uapsta.bin \
    $(LOCAL_PATH)/proprietary/bin/mlaninit.sh:system/bin/mlaninit.sh \
    $(LOCAL_PATH)/proprietary/bin/mlanutl:system/bin/mlanutl \
    $(LOCAL_PATH)/proprietary/bin/tinymix:system/bin/tinymix \
    $(LOCAL_PATH)/proprietary/bin/mlan2040coex:system/bin/mlan2040coex \
    $(LOCAL_PATH)/proprietary/bin/set_macaddr:system/bin/set_macaddr \
    $(LOCAL_PATH)/proprietary/bin/wifi_reset.sh:system/bin/wifi_reset.sh \
    $(LOCAL_PATH)/proprietary/bin/copy_calib.sh:system/bin/copy_calib.sh

# All of the above are pure prebuilt binaries installed via PRODUCT_COPY_FILES
# (no source, so no PRODUCT_PACKAGES / LOCAL_MODULE entries for them).
