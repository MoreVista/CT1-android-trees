DEVICE_PATH := device/benesse/40S404

# Platform
TARGET_BOOTLOADER_BOARD_NAME := SABRESD
TARGET_BOARD_PLATFORM := imx6
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Architecture (i.MX6 Solo/DualLite, dual Cortex-A9 -- UART shows
# "CPU identified as i.MX6DL/SOLO" / "Brought up 2 CPUs" on the real unit,
# despite the "6Q" in some build strings; Solo/DualLite/Quad all share the
# Cortex-A9 core so this doesn't change the toolchain target)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a9
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

# Kernel: reused verbatim from the stock device, same as the TWRP port
# (see ../../../40s404-twrp/twrp-build-40s404.md). boot.img and
# recovery.img on the real unit ship the identical kernel blob (md5
# f3b3de4f3651acf70a5e88988f83b05f). Reusing it unmodified is required
# here, not just convenient: the WiFi driver (mlan.ko/sd8787.ko) are
# prebuilt out-of-tree modules pulled from the stock /system with no
# source in the GPL kernel dump, and would need to match the exact
# kernel module ABI (vermagic) a rebuild might not reproduce.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/zImage
BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,bpp=32 video=mxcfb1:off video=mxcfb2:off fbmem=10M fb0base=0x27b00000 vmalloc=400M androidboot.console=ttymxc0 androidboot.hardware=freescale
BOARD_KERNEL_BASE := 0x10800000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100

# Partitions (live values read from the real unit, same as the TWRP port).
# mmcblk0: p1=boot p2=recovery p3=extended-container p4=data p5=system
# p6=cache p7=device(content) p8=factory
BOARD_BOOTIMAGE_PARTITION_SIZE     := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 8388608
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 528482304
BOARD_USERDATAIMAGE_PARTITION_SIZE := 13539213312
BOARD_CACHEIMAGE_PARTITION_SIZE    := 528482304
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE  := ext4
BOARD_FLASH_BLOCK_SIZE := 131072
TARGET_USERIMAGES_USE_EXT4 := true

# Recovery (CM10.1's own built-in recovery, not TWRP -- TWRP is flashed
# separately from the sibling 40s404-twrp project when wanted).
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
RECOVERY_SDCARD_ON_DATA := true

# Graphics: Vivante GC350 (gc_hal_kernel source is in the GPL kernel dump
# under drivers/mxc/gpu-viv, built from TARGET_KERNEL_SOURCE below; the
# userspace libGAL/libEGL_VIVANTE/etc. are closed blobs pulled from stock
# -- see vendor/benesse/40S404/proprietary-files.txt).
USE_OPENGL_RENDERER := true
BOARD_EGL_CFG := $(DEVICE_PATH)/configs/egl.cfg
TARGET_HARDWARE_3D := true

# WiFi: Marvell sd8787 over SDIO, mlan.ko + sd8787.ko (out-of-tree, prebuilt,
# loaded in that order -- see init.40S404.rc). Starting with NL80211 per
# modern wpa_supplicant default; this chip/driver generation may turn out
# to need WEXT instead -- revisit if wpa_supplicant fails to attach.
BOARD_WLAN_DEVICE := mrvl
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_FW_PATH_PARAM := "/dev/null"

TARGET_USES_LOGD := true
