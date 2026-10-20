# Android 7.1.2 (LineageOS 14.1) on the Benesse 40S404

Branch `android-7.1-lineage14.1` (ROM base: LineageOS 14.1 (cm-14.1)). See the repository's `main` branch for the overview and for what is not included.

Status: boots to a fully working UI: HWC composition without tearing (fb pan/vsync race fixed), Wi-Fi, audio, SD card/MTP, sensors, root via `WITH_SU`, Freescale VPU decoding straight into gralloc buffers (1080p30 H.264), screencap/Recents thumbnails. **Not working:** camera, WebView `<video>` (no picture), VP8. The kernel is still the stock 3.0.35 (no SELinux, no seccomp), so the tree contains patches that remove SELinux from init/adbd/installd/debuggerd. Details and the long list of root causes: `device/benesse/40S404/NOTES.md`.

## Build

Source tree: LineageOS `cm-14.1` (`repo init -u https://github.com/LineageOS/android.git -b cm-14.1`). The author built in a Ubuntu 14.04 chroot (bubblewrap); about 12 minutes for `mka bacon` with a warm ccache. `/system` is only 504 MB on this tablet: `WebViewGoogle.apk` is installed as a user app, not into the image. WebView provider: see the note in `device/benesse/40S404/webview/Android.mk`.

1. Put the stock blobs in place: `cd vendor/benesse/40S404 && ./extract-files.sh` (see `vendor/benesse/40S404/README.md`).
2. Provide `device/benesse/40S404/prebuilt/zImage` (the stock kernel).
3. Apply the patches in `device/benesse/40S404/patches/` to the AOSP projects they are named after
   (`frameworks_av-foo.patch` -> `git -C frameworks/av apply <patch>`, `system_core-*` -> `system/core`, ...).
4. `source build/envsetup.sh && lunch cm_40S404-userdebug && mka bacon`
5. Flash the zip with TWRP (the author's TWRP port of this device is a separate project).
   First boot after flashing is slow (dex2opt); wipe the dalvik cache when updating from a previous build.

`build.sh.example` is the wrapper the author used (path names are specific to his machine).
