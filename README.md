# Benesse 40S404 (Challenge Pad / Challenge Touch) -- Android device trees, one branch per Android version

Work in progress community ports of the **Benesse 40S404-01** tablet (Freescale i.MX6 Quad "bee01", 1024x768, kernel 3.0.35,
Vivante GPU, Freescale VPU) to newer Android versions, kept as one repository with one branch per Android release.
A sibling tablet, the Benesse **41EA04**, was ported to CyanogenMod 11 as well (branch `android-4.4-cm11-41EA04`).

| Branch | Android | ROM base | Notes |
|---|---|---|---|
| [`android-4.2-cm10.1`](../../tree/android-4.2-cm10.1) | 4.2.2 | CyanogenMod 10.1 | first port; contains the rebuild kit (manifests + patches + Docker image recipe) |
| [`android-4.4-cm11`](../../tree/android-4.4-cm11) | 4.4 | CyanogenMod 11 | |
| [`android-4.4-cm11-41EA04`](../../tree/android-4.4-cm11-41EA04) | 4.4 | CyanogenMod 11 | `android-4.4-cm11` + the 41EA04 device/vendor trees |
| [`android-5.1-cm12.1`](../../tree/android-5.1-cm12.1) | 5.1 | CyanogenMod 12.1 | camera does not work (see NOTES.md) |
| [`android-7.1-lineage14.1`](../../tree/android-7.1-lineage14.1) | 7.1.2 | LineageOS 14.1 | newest; most notes (NOTES.md): HWC flicker fix, zero-copy VPU video, Wi-Fi, root |

The branches are a real history: every branch continues the previous one (`4.2 -> 4.4 -> 5.1 -> 7.1`), so `git log` / `git diff`
between branches shows exactly what had to change per Android version.

## Layout (every branch)

```
device/benesse/40S404/     device tree: BoardConfig, init rc, overlays, configs, patches/ for AOSP projects, NOTES.md
vendor/benesse/40S404/     vendor makefiles + extract-files.sh  (the proprietary blobs themselves are NOT included)
```
Copy/symlink these two directories to the same paths inside your CyanogenMod / LineageOS source tree, then
`lunch cm_40S404-userdebug` and `mka bacon`. `device/benesse/40S404/NOTES.md` is the engineering log of that Android version
(what was broken, the root causes, how it was debugged) -- the most useful file in the repository if you port a similar
i.MX6 / Vivante device.

## What is deliberately NOT in this repository

* **Proprietary vendor blobs** (Benesse/Freescale/Vivante libraries, VPU firmware, Marvell Wi-Fi modules, ...). Run
  `vendor/benesse/40S404/extract-files.sh` against your own tablet / stock firmware. `proprietary-files.sha256` lets you verify
  the result, README.md next to it lists the few blobs that were modified (patchelf).
* **The prebuilt kernel** `device/benesse/40S404/prebuilt/zImage`. The ROMs reuse the stock kernel (3.0.35, no SELinux)
  verbatim: take the `zImage` out of your stock `boot.img`/`recovery.img`. The kernel source dump Benesse published is at
  <https://github.com/puhitaku/40s404-01-source-code>.
* **Google's WebView APK** used on the 7.1 branch (`device/benesse/40S404/webview/WebViewGoogle.apk`, Chrome 95 WebView, armeabi-v7a).
  Without it remove the `webview` module from the product makefile or provide your own APK at that path.
* Build outputs, logs, the author's private backups and device serial numbers (replaced by placeholders).

## Hardware status (7.1 branch, the most complete)

Works: display (HWC composition without tearing), touch, Wi-Fi, audio, SD card/MTP, sensors,
H.264/MPEG-4 playback through the VPU (zero copy, 1080p30), root (`WITH_SU`).
Not working: camera (also not on 5.1), WebView `<video>` (no picture), VP8 decoding.

## License

The device-specific files follow the license of the project they plug into (Apache-2.0 for AOSP/LineageOS parts; patches are
derived from AOSP/LineageOS sources and carry the license of the patched project). No guarantee, you can brick your tablet.
