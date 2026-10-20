# Android 5.1 (CyanogenMod 12.1) on the Benesse 40S404

Branch `android-5.1-cm12.1` (ROM base: CyanogenMod 12.1 (cm-12.1)). See the repository's `main` branch for the overview and for what is not included.

Status: used as a daily ROM on the author's tablet: display (v_hwc), touch, Wi-Fi, audio, sensors, SD card, VPU video work. **Camera does not work** (see NOTES.md, section on the camera). Details: `device/benesse/40S404/NOTES.md`.

## Build

Source tree: `repo init -u https://github.com/CyanogenMod/android.git -b cm-12.1 --depth=1` (CyanogenMod organisation is archived: use the LineageOS mirrors; `prebuilts/tools` and `prebuilts/qemu-kernel` are needed, `external/qemu` can be removed). Build environment: Ubuntu 14.04 userland (the author used a Docker image, see `build.sh.example`).

1. Put the stock blobs in place: `cd vendor/benesse/40S404 && ./extract-files.sh` (see `vendor/benesse/40S404/README.md`).
2. Provide `device/benesse/40S404/prebuilt/zImage` (the stock kernel).
3. Apply the patches in `device/benesse/40S404/patches/` to the AOSP projects they are named after
   (`frameworks_av-foo.patch` -> `git -C frameworks/av apply <patch>`, `system_core-*` -> `system/core`, ...).
4. `source build/envsetup.sh && lunch cm_40S404-userdebug && mka bacon`
5. Flash the zip with TWRP (the author's TWRP port of this device is a separate project).
   First boot after flashing is slow (dex2opt); wipe the dalvik cache when updating from a previous build.

`build.sh.example` is the wrapper the author used (path names are specific to his machine).
