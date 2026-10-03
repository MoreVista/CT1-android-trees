# CM10.1 bring-up notes (Benesse 40S404 / i.MX6 "bee01")

Status (2026-10-03): boots, lockscreen/UI render on GPU (GLES2/HWUI), adb, WiFi (Marvell sd8787) up.

## Root causes found (in order of discovery)
1. **Blank/white/black UI** -- `libGLSLC.so` (Vivante GLSL compiler, dlopen'd by
   libGLESv2_VIVANTE) was missing from the blob list. Every `glCompileShader`
   failed silently, so HWUI (all UI is GLES2) drew nothing. Bootanimation is
   GLES1 and kept working, which made it look like a SurfaceFlinger/fb problem.
   Diagnosis: tiny native clients in `external/sftest` (not in this repo):
   SW-filled surface (worked) and a GLES2 clear+shader quad (shader fail).
   Also added `libg2d.so` (hwcomposer_viv) and `libion.so`.
2. **Phone app crash loop / signature perms denied** -- /data kept the stock
   `packages.xml`. System apps have identical mtimes (2008-08-01) so PM reuses
   persisted signatures: `android`, Settings, SystemUI were still tied to the
   *stock Benesse platform key* while the new build is signed with the AOSP
   platform key. Fix applied on the unit: replace the key bytes of `<cert index=1>`
   in /data/system/packages.xml with the AOSP platform cert (backups:
   packages.xml.stockbak / .pre-certfix). A clean /data (factory reset) avoids this.
3. **fs_mgr_mount_all error** -- `/device` mountpoint did not exist.
4. **WiFi** -- first sd8787 SDIO probe after boot fails (-1) unless the chip is
   power-cycled via /sys/devices/platform/wifi_reset.0/wifi_reset first; stock
   insmod args: `drv_mode=1 cfg80211_wext=4 sta_name=wlan`. See `wifi_load.sh`.

5. **Backlight "won't turn on" / power key dead** -- CM10.1's
   `PhoneWindowManager.interceptKeyBeforeQueueing` NPEs on KEYCODE_POWER when there
   is no fullscreen top window (`mTopFullscreenOpaqueWindowState == null`). That
   happened because a 2nd HOME app (Nova, from /data) made HOME a chooser dialog.
   The screen then sat in DIM (brightness 9/248) and no key/sleep worked.
   Fix: null-guard patch in `patches/` (apply to frameworks/base); on the unit Nova
   was disabled (`pm enable com.teslacoilsw.launcher` to undo).
   Verified with `sendevent /dev/input/event0 1 116 ...` (real gpio-keys path;
   `input keyevent` injection does not exercise user-activity the same way).

6. **No adb / hot "android_usb: already disabled" loop after wiping /data** -- on a
   fresh Settings DB the ADB_PORT insert fires UsbDeviceManager's AdbSettingsObserver,
   which read the missing ADB_ENABLED row as 0, disabled adb and persisted
   `persist.sys.usb.config=none`. Fix: `patches/frameworks_base-UsbDeviceManager-adb-default.patch`.
   Manual recovery from TWRP: write `adb` to /data/property/persist.sys.usb.config and
   insert `adb_enabled=1` into settings.db (global table; remove -wal/-shm, chown 1000).

7. **WiFi not usable from the UI on fresh /data** -- /data/misc/wifi/sockets did not
   exist (stock init.rc created it). libhardware_legacy's wpa_ctrl binds its client
   socket there, so every connect failed ENOENT. Added mkdir in `on post-fs-data`.
   ("softap fwreload ... failed" in the log is harmless on this driver.)
8. **Touch offset** -- rohm_bu21025 declares 0-1024 x 0-768 but produces X 40-936,
   Y 70-732. `patches/frameworks_base-EventHub-idc-abs-range.patch` lets the .idc
   override ranges (`abs.<code>.min/max`); also needs rohm_bu21025.idc
   (`touch.deviceType = touchScreen`, otherwise it is treated as a touchpad/mouse).
9. **Speaker silent** -- wm8978 right speaker/mixer path off by default; `audio_init.sh`
   sets it at boot (needs `libtinyfsl.so` = stock libtinyalsa with control_open, and a
   patched DT_NEEDED in audio.primary.imx6.so).

10. **Stuck on "Obtaining IP address"** -- no `dhcpcd_wlan0` service in our rc (stock had it
   in init.rc) and no /data/misc/dhcp. Added both. Verified manually:
   `dhcpcd -ABKL wlan0` leases an address.
11. **Settings had no Wi-Fi entry** -- /system/etc/permissions feature XMLs (wifi,
   accelerometer, usb host/accessory, faketouch, touchscreen, location) were missing.

## Gotchas
- Never `ctl.restart surfaceflinger` for experiments: system_server keeps a stale
  display token ("Attempt to blank null display", mDisplayReady=false).
- logcat ring buffer is flooded by crash loops; clear it before reproducing.
- Flash path: `adb reboot recovery`, push zip to /sdcard, `twrp install` in the background.

## Open
- Media codecs (VPU: libvpu, lib_vpu_wrapper, stagefright hw) and audio_policy.conf / media_codecs.xml not ported.
- Stock init.rc exports (VPU_FW_PATH, shm mounts) not ported.
- Two HOME apps (Launcher2 + Trebuchet) => "Complete action using" chooser.
