# Android 4.2.2 (CyanogenMod 10.1) on the Benesse 40S404

Branch `android-4.2-cm10.1` (ROM base: CyanogenMod 10.1 (cm-10.1)). See the repository's `main` branch for the overview and for what is not included.

Status: first port of the tablet to CyanogenMod; boots with display, touch, Wi-Fi, audio, VPU video (Freescale OMX) working. Details and the list of problems solved: `device/benesse/40S404/NOTES.md`.

## Build

Source tree: `repo init -u https://github.com/CyanogenMod/android.git -b cm-10.1` plus the local manifest and patches in `rebuild-kit/` (the CyanogenMod GitHub organisation is archived, `rebuild-kit/manifests/pinned-shas.txt` lists the exact commits of the last build). Build environment: Ubuntu 12.04 (`rebuild-kit/Dockerfile.cm10.1-build-12.04`).

1. Put the stock blobs in place: `cd vendor/benesse/40S404 && ./extract-files.sh` (see `vendor/benesse/40S404/README.md`).
2. Provide `device/benesse/40S404/prebuilt/zImage` (the stock kernel).
3. Apply the patches in `device/benesse/40S404/patches/` to the AOSP projects they are named after
   (`frameworks_av-foo.patch` -> `git -C frameworks/av apply <patch>`, `system_core-*` -> `system/core`, ...).
4. `source build/envsetup.sh && lunch cm_40S404-userdebug && mka bacon`
5. Flash the zip with TWRP (the author's TWRP port of this device is a separate project).
   First boot after flashing is slow (dex2opt); wipe the dalvik cache when updating from a previous build.

`build.sh.example` is the wrapper the author used (path names are specific to his machine).
