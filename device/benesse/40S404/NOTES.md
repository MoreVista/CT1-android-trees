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

## Gotchas
- Never `ctl.restart surfaceflinger` for experiments: system_server keeps a stale
  display token ("Attempt to blank null display", mDisplayReady=false).
- logcat ring buffer is flooded by crash loops; clear it before reproducing.
- Flash path: `adb reboot recovery`, push zip to /sdcard, `twrp install` in the background.

## Open
- Media codecs (VPU: libvpu, lib_vpu_wrapper, stagefright hw) and audio_policy.conf / media_codecs.xml not ported.
- Stock init.rc exports (VPU_FW_PATH, shm mounts) not ported.
- Two HOME apps (Launcher2 + Trebuchet) => "Complete action using" chooser.
