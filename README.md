# Android 4.4 (CyanogenMod 11) on the Benesse 40S404

Branch `android-4.4-cm11` (ROM base: CyanogenMod 11 (cm-11.0)). See the repository's `main` branch for the overview and for what is not included.

Status: boots, display/touch/Wi-Fi/audio/VPU video work. Details: `device/benesse/40S404/NOTES.md`. The sibling tablet 41EA04 is on branch `android-4.4-cm11-41EA04`.

## Build

Source tree: `repo init -u https://github.com/CyanogenMod/android.git -b cm-11.0` (the CyanogenMod GitHub organisation is archived: use the LineageOS mirrors of the same project names, `repo sync -c --no-tags`). Build environment: Ubuntu 14.04 userland (the author used a Docker image, see `build.sh.example`).

1. Put the stock blobs in place: `cd vendor/benesse/40S404 && ./extract-files.sh` (see `vendor/benesse/40S404/README.md`).
2. Provide `device/benesse/40S404/prebuilt/zImage` (the stock kernel).
3. Apply the patches in `device/benesse/40S404/patches/` to the AOSP projects they are named after
   (`frameworks_av-foo.patch` -> `git -C frameworks/av apply <patch>`, `system_core-*` -> `system/core`, ...).
4. `source build/envsetup.sh && lunch cm_40S404-userdebug && mka bacon`
5. Flash the zip with TWRP (the author's TWRP port of this device is a separate project).
   First boot after flashing is slow (dex2opt); wipe the dalvik cache when updating from a previous build.

`build.sh.example` is the wrapper the author used (path names are specific to his machine).
