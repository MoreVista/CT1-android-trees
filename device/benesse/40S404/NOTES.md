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

12. **MTP showed no storage** -- MountService registered `/mnt/sdcard` (framework default,
   non-existent) and vold, having no /system/etc/vold.fstab, auto-added an `sdcard`
   volume at the same path => NPE "Error processing initial volume state". Fixed with
   `overlay/.../storage_list.xml` (emulated primary /storage/sdcard0, SD slot, USB host)
   and `vold.fstab` (stock sysfs paths). MTP needs `persist.sys.usb.config=mtp,adb`
   (set via Settings > Storage > USB computer connection, or `setprop`).
   Host note: gvfs-mtp grabbing the device makes the host adb server drop it;
   unmount (`gio mount -u mtp://...`) and `adb kill-server; adb start-server`.

13. **No video playback ("Failed to instantiate decoder")** -- /system/etc/media_codecs.xml
   was missing so stagefright knew no codecs. Added a software-only list
   (OMX.google.*). stagefright decode: 240p 395 fps, 480p ~95-110 fps. The VPU
   (OMX.Freescale.* + libvpu/lib_vpu_wrapper) is NOT ported; HD video will be CPU-bound.

14. **App OOM (SkyTube "playback error")** -- no dalvik.vm.heap* props, so the VM used its
   16 MB default heap. Added the stock values (heapgrowthlimit 64m, heapsize 384m...).

15. **Hardware video decode (Freescale VPU) + CPU render** -- ported the stock OMX stack:
   `lib_omx_*`, `libvpu`, `lib_vpu_wrapper`, `libstagefrighthw` (vendor `40S404-omx.mk`), VPU firmware
   (/system/lib/firmware/vpu), the three *_register files, the stock `media_codecs.xml`, and the init
   exports (CORE/COMPONENT/CONTENTPIPE_REGISTER_FILE, VPU_FW_PATH, SHM_MOUNTPOINT=/mnt/shm tmpfs) --
   they must be in init's environment so mediaserver AND app processes inherit them.
   Software H.264 (OMX.google, On2) is Baseline only and fails with STRM_ERR(-2) on High/Main-profile
   YouTube streams; the VPU decodes them.
   **Rendering**: with `persist.sys.fsl.hwrender=1` (default) the VPU decodes straight into gralloc
   buffers (zero copy). With 0, `OMX.Freescale.*` is treated like `OMX.google.*` (no native window;
   AwesomeLocalRenderer / MediaCodec SoftwareRenderer colour-convert on the CPU). Zero-copy needed:
   the OMX->HAL colour-format map (19->0x101, 21->0x103, 22->0x100, 6->RGB565), minUndequeued=0 like
   stock (every buffer goes to the VPU), the BufferQueue min-undequeued check removed
   (`patches/frameworks_native-BufferQueue-*.patch`), and holding back the refill after the *first*
   rendered frame (ACodec/OMXCodec `mFslFirstRenderDone`): otherwise the single looper blocks in
   dequeueBuffer waiting for SurfaceFlinger to release the previous frame while the VPU waits for a
   buffer back (deadlock). All in `patches/frameworks_av-fsl-vpu-decode-sw-render.patch`.
   Never swap libstagefright.so on a running system: zygote keeps the old mapping and every new app
   dies with SIGSEGV at pc 0x463fc (the PLT0 stub). Reboot after live pushes.
17. **Navigation bar** -- `qemu.hw.mainkeys=0`.
   Debug aids: /data/omx_log_level, /data/vpu_log_level (need mediaserver restart);
   `LOG_NDEBUG 0` at the top of ACodec.cpp/MediaCodec.cpp gives the full state machine.
16. **build.prop is not regenerated when only product properties change** -- delete
   out/target/product/40S404/system/build.prop before `mka bacon` after editing PRODUCT_PROPERTY_OVERRIDES.

## Gotchas
- Never `ctl.restart surfaceflinger` for experiments: system_server keeps a stale
  display token ("Attempt to blank null display", mDisplayReady=false).
- logcat ring buffer is flooded by crash loops; clear it before reproducing.
- Flash path: `adb reboot recovery`, push zip to /sdcard, `twrp install` in the background.

## Open
- Media codecs (VPU: libvpu, lib_vpu_wrapper, stagefright hw) and audio_policy.conf / media_codecs.xml not ported.
- Stock init.rc exports (VPU_FW_PATH, shm mounts) not ported.
- Two HOME apps (Launcher2 + Trebuchet) => "Complete action using" chooser.

---
# CM11 (4.4.4) port notes

Build: docker `cm11-build:14.04`, `lunch cm_40S404-userdebug` (not eng: eng forces CheckJNI = very slow).
Flash via TWRP; install is only done when `/tmp/updater` has exited (verify md5 of a lib in /system).

## Findings
1. Stock 4.2 /data carried over: Trebuchet DB incompatible -> `pm clear com.cyanogenmod.trebuchet`.
2. Touch offset: EventHub idc `abs.<code>.min/max` override patch (panel range X 40-936, Y 70-732).
3. Slow: conservative@396MHz -> set `interactive` governor in init.freescale.rc.
4. WiFi: KitKat needs separate `wpa_supplicant` / `p2p_supplicant` services (`-O/data/misc/wifi/sockets -g@android:wpa_wlan0`), no stock wpa_supplicant.conf.
5. `ro.zygote.disable_gl_preload=true`: preloading GL in zygote SIGSEGVs in stock libGAL.
6. auditd respawns forever (kernel lacks audit netlink) -> `stop auditd` in `on boot`.
7. BufferQueue: the min-undequeued check must be skipped ONLY for the FSL YUV formats (0x100-0x103).
   Removing it globally lets GL clients (bootanimation, ...) dequeue every free buffer and deadlock
   (random freeze at the first bootanimation frame, bootanim never exits).
8. Video (persist.sys.fsl.hwrender=1): port of the CM10.1 patch to OMXCodec/ACodec/AwesomePlayer/MediaCodec
   (HAL format mapping, minUndequeued=0, skip first dequeue after first render).
9. Stock libstagefrighthw.so (FSLOMXWrapper::DoUseNativeBuffer) recovers the GraphicBuffer from the
   ANativeWindowBuffer pointer with "- 4" (JB 4.2 layout). KitKat has ANativeWindowBuffer at offset 0,
   so OMXNodeInstance::useGraphicBuffer passes GraphicBuffer+4 (otherwise SIGSEGV in GraphicBufferMapper::lock).
10. adb: `ro.adb.secure=0` in device mk; `adb root` needs Settings > Developer > Root access = Apps and ADB.
11. Bootanimation is LineageOS's (vendor/cm cm-11.0 branch), not a bug.

## Patches (apply to the CM11 tree)
see patches/*.patch (frameworks_av, frameworks_native, frameworks_base EventHub, dalvik zygote fd whitelist,
system_core VectorImpl shims). Also hand-edited: libutils Unicode.cpp, art/libnativehelper build fixes,
build/tools/releasetools/edify_generator.py (set_perm instead of set_metadata).

---
# CM12.1 (Android 5.1.1, cm-12.1) port notes

Tree: /mnt/hdd/40s404-cm12/src (repo init -b cm-12.1 --depth=1; prebuilts/tools and prebuilts/qemu-kernel are
needed, external/qemu(+pc-bios) removed). Build: docker `cm11-build:14.04`, `lunch cm_40S404-userdebug`, `mka bacon`.
Iteration shortcut: `adb root` (needs Settings > Developer options > Root access = Apps and ADB), `adb remount`,
`adb push` the lib, reboot. Patches live in patches/*.patch (apply to the matching repo of the CM12.1 tree).

## What had to change vs. CM11
1. updater-script: Lollipop's updater has no set_perm; the default set_metadata_recursive (no selabel) works. Do NOT keep
   the CM11 edify_generator patch.
2. libutils: Lollipop's `reservedVectorImpl*` are `#ifdef NEEDS_VECTORIMPL_SYMBOLS` again -> same symbol shims as CM11
   (patches/VectorImplShims.cpp + system_core-libutils-vectorimpl-shims.patch).
3. libbinder: stock gralloc_viv.imx6.so needs the non-const IPCThreadState::getCallingPid() -> shim
   (patches/frameworks_native-all-cm12.patch). Without it gralloc fails to dlopen -> every buffer alloc fails.
4. libgui BufferQueueProducer: stock Vivante EGL expects the pre-L error codes (-EINVAL for "multiple dequeue without
   buffer count", -EBUSY for min-undequeued); the min-undequeued check is skipped for the FSL YUV formats 0x100-0x103
   (VPU video) only. Removing it for everything deadlocks GL clients (see CM11 notes).
5. zygote fd whitelist (frameworks/base core/jni/fd_utils-inl.h), EventHub idc abs range (frameworks/native inputflinger).
6. Feature XML (configs/40s404_core_hardware.xml): without android.software.app_widgets etc. system_server does not
   start AppWidgetService and Trebuchet crashes.
7. VPU: the VPU shared memory is at physical 0xddf84000 (> 2 GB); L's bionic mmap() rejects the negative 32-bit off_t.
   BOARD_USES_LEGACY_MMAP := true (and touch bionic/libc/bionic/mmap.cpp - flag changes alone do not rebuild libc).
8. Video: CM11 FSL patches ported to OMXCodec/ACodec/AwesomePlayer/MediaCodec (frameworks_av patch) incl. the
   OMXNodeInstance GraphicBuffer+4 layout fix.
9. Camera: camera.imx6.so needs libjhead in ITS OWN DT_NEEDED (L's linker only searches direct deps of a dlopen'd lib):
   patched with `patchelf --add-needed libjhead.so` (vendor repo) + libcamera_client links libjhead.
   STILL NOT WORKING: the stock HAL is a JB 4.2 camera2 (HAL2.0) implementation; MetadaManager::createStaticInfo fails
   because 4.2's camera_metadata tag numbering differs from L's (e.g. tag 0x00020001 does not exist). Making it work needs a
   new HAL1 (V4L2, sr200pc20 at /dev/video0) - there is no FSL HAL source in this tree.
10. HWUI: the Vivante driver does not draw vertex-alpha (AA tessellated) round-rect fills -> Material dialog backgrounds
    were fully transparent. OpenGLRenderer::drawRoundRect always uses the PathCache texture route
    (patches/frameworks_base-hwui-roundrect-texture.patch).
11. screencap is black/white (SurfaceFlinger GL read-back unsupported); to look at the screen use a framebuffer dumper
    (open /dev/graphics/fb0, mmap, dump the page at yoffset; the pages repeat).

## LineageOS 14.1 (7.1.2) -- performance / graphics findings

Debug root: `WITH_SU := true` (cm.mk) + `su_daemon` service in init.freescale.rc (this init does not read
/system/etc/init). `adb root` works (adbd is patched for the SELinux-less kernel); if `adb root` leaves the
host stuck, `adb kill-server` and retry. After a reboot adbd is non-root again.

1. **UI slow (~10 fps)** -- LiveDisplay (night colour temperature) sends a non-identity colour matrix to
   SurfaceFlinger (transaction 1030); `SurfaceFlinger_hwc1.cpp` then marks every layer HWC_SKIP_LAYER and
   composites all on the GC880 with an extra colour shader. Fix: `overlay/vendor/cmsdk/.../config.xml`
   (LiveDisplay off by default) and `patches/frameworks_native-sf-hwc-policy.patch` (identity matrix = none).
2. **Screen corruption with HWC enabled** -- the stock Freescale v_hwc blit composition corrupts the screen on
   N. SurfaceFlinger now composites with GLES unless `ro.sf.use_hwc=1` (same patch). Cost: ~26-36 ms/frame
   scrolling Settings vs ~9 ms with v_hwc.
3. **App cold start ~3 s** -- libEGL's Loader::init_api() asked the Vivante eglGetProcAddress() for ~8700 names
   per process; every unanswered call dlopen()s (libGAL gcoOS_LoadLibrary) and Android 7's linker does ~50
   mprotect() per dlopen (found with `strace -f -tt` on the app: 55k mprotect, 457 dlopen of libGLESv1_CM.so).
   The only names it resolved beyond dlsym() were 49 unadvertised stubs (APPLE/NV/QCOM/IMG). Fix:
   `patches/frameworks_native-libegl-loader.patch` (dlsym only; `debug.egl.use_gpa=1` restores the old
   behaviour). Settings 3.6 s -> 1.4 s, Calculator 3.0 s -> 1.3 s.
4. **zygote GL preload still impossible** (`ro.zygote.disable_gl_preload=true` stays): the Vivante libs open
   /dev/galcore in a static constructor, so the zygote's galcore fd/GAL state is shared with every forked child
   and a Vivante thread in system_server dies with SIGSEGV (fault addr 0x903100) ~20 s after start.
5. ART is NOT the bottleneck: `cmd package compile -m speed` on Calculator changed nothing; JIT stays off.
   /system is 96 % full, so no system-wide dexpreopt anyway.
6. Misleading numbers: `top` shows ~25-50 % IOW at idle (ipu1_task kthreads sit in D state) and load average
   ~5; `adb shell screencap` is all-black (GL readback); with CM ROMs the 41EA04 reports the same adb serial
   (0123456789ABCDEF) -- always select the device by `adb -t <transport_id>` after checking ro.product.device.

### v_hwc (hardware composer) corruption -- investigation log (2026-10-17)

Tooling: `/dev/graphics/fb0` is readable as root; a tiny static C tool (`fbcap`, built with the tree's
arm-linux-androideabi-gcc + ndk android-10 sysroot) reads `FBIOGET_VSCREENINFO.yoffset` and copies the page
that is actually displayed (yres_virtual=2304 = 3 pages); frames converted with PIL (BGRA). This beats
screencap (all black). Capture ~24 frames while swiping the launcher.
Do NOT toggle HWC at run time (`service call SurfaceFlinger 1008`): it left apps with
"dequeueBuffer: attempting to exceed the max dequeued buffer count (2)" -> EGL_BAD_NATIVE_WINDOW ->
HWUI "halting rendering" (frozen Launcher/StatusBar). Use ro.sf.use_hwc=1 + reboot for experiments.

Symptom with ro.sf.use_hwc=1: in ~5-8 % of frames of a scrolling animation the composed frame (as stored in
the displayed fb page) has horizontal bands from different frames: wallpaper polygon edges notched at a
fixed y, launcher icon labels clipped. Static screens, Settings scrolling and GLES composition are clean.
The displayed page is never modified after flip (checked with `fbmut`), so the tear is inside the composed
result, not scan-out.
Facts about hwcomposer_viv.imx6.so: no sync_wait import (acquire fences ignored); g2d_finish() of the
blits is deferred to the next compose (flag at ctx+172); it has Area/owners bookkeeping.
Tried without effect: debug.egl.finish=1; Layer maxAcquiredBufferCount=2; forcing HWC_GEOMETRY_CHANGED
every frame. Marking only the wallpaper SKIP makes v_hwc fall back to GLES for *all* layers (no hybrid).
Conclusion: keep GLES composition (ro.sf.use_hwc unset); resolving the tear needs reverse engineering of
hwcComposeG2D (Area splitting) or a replacement HWC.

## LineageOS 14.1 -- flashing / release checklist (2026-10-17)

* Flash: `adb reboot recovery` (TWRP, serial <40S404-twrp-serial>) -> `adb push <zip> /data/los14.zip` -> `twrp install /data/los14.zip`
  -> `twrp wipe dalvik` -> reboot. The first boot after an OTA takes ~5-10 min (installd dex2oat of the
  framework jars); do not judge it before sys.boot_completed.
* **make never deletes stale files from `out/target/product/40S404/system`.** A leftover `lib/hw/power.imx6.so`
  (stock power HAL, removed from the vendor makefile long ago) ended up in the first full image and made
  system_server die with SEGV_ACCERR right after PowerManagerService init ("SWITCHPROFILE ... Power HAL" in
  logcat is the tell-tale). Delete stale output files after removing something from a makefile, then rebuild.
* WebView: `adb install webview/WebViewGoogle.apk` (user app, not part of the image; /system is 96 % full).
* The kernel cmdline is plain again (no user_debug, no init=/init); u-boot appends ~88 chars, total < 300.

### App freezes: "attempting to exceed the max dequeued buffer count" (2026-10-17)

Symptom: opening the Launcher's all-apps list froze the Launcher (no redraw). Log: `BufferQueueProducer: [..Launcher]
dequeueBuffer: attempting to exceed the max dequeued buffer count (2)` followed by HWUI `swapBuffers encountered EGL error
12299 ... halting rendering...`; HWUI then drops the surface for good. Reproduced in ~25 % of drawer opens
(`sendevent` tap loop, see drawer3.sh idea: tap 512,672 / tap 512,744 with 0.8 s sleeps; `input tap` itself spawns a JVM
and drives the 800 MB device into the low-memory killer, which makes the test meaningless).
Cause: the Vivante EGL dequeues the next buffer before the previous frame's queueBuffer has landed in SurfaceFlinger, so
for a moment 3 buffers are dequeued; maxDequeued is 2. Raising maxDequeued to 3 does not help (still fails).
Fixes: (1) `ro.bq.dequeue_wait_ms=100` -- libgui BufferQueueProducer waits for the in-flight queue instead of failing
(patches/frameworks_native-bq-dequeue-wait.patch, also contains an inactive `ro.bq.min_max_dequeued` clamp);
result 0 failures / 100 opens. (2) HWUI safety net: on a failed swap re-create the EGL surface instead of dropping it
(patches/frameworks_base-hwui-swap-recover.patch).
The producer side runs inside surfaceflinger, so libgui changes need a reboot (zygote restart is not enough).

### Video playback (FSL VPU) on N (2026-10-17)

Result: H.264 (320x240, 848x480) plays through the VPU decoder `OMX.Freescale.std.video_decoder.avc.v3.hw-based`
with CPU rendering (ACodec software-renderer route), ~28 fps for 480p at ~27 % CPU. Zero-copy (native window, HAL
formats 0x100-0x103, persist.sys.fsl.hwrender=1) is NOT ported to N; 720p+ is untested.
Why it did not work, in order (each hid the next):
1. AOSP 7.1 MediaCodecList instantiates every XML codec once (QueryCapabilities) and drops the ones that fail, silently
   -> all OMX.Freescale.* vanished and OMX.google.* (software) was used. Look for `FAILED to allocate omx component`.
2. dlopen of the VPU chain failed: lib_id3_parser needs `String8::setTo(unsigned short const*, unsigned)` (char16_t
   mangling changed) -> shim in libutils/VectorImplShims.cpp.
3. The components run in the `media.codec` process (uid mediacodec) which could not open /dev/mxc_vpu and /dev/ion
   (0660 media:system) -> ueventd.freescale.rc 0666.
4. libvpu calls g2d_alloc -> gcoOS_AllocateVideoMemory without constructing the Vivante GAL; in media.codec nobody did
   (SIGSEGV, fault addr 0x10 in libGAL) -> OMXMaster calls g2d_open() once (fslInitGal).
5. ACodec: FSL components cannot take the native-window route (gralloc rejects the raw OMX colour format, ENOMEM) ->
   treat OMX.Freescale.* like OMX.MARVELL.* (forceSwRenderer).
6. The decoder advertises stride/slice-height 0 -> SoftwareRenderer put the chroma planes at offset 0 (garbage grid) ->
   fall back to nFrameWidth/nFrameHeight in ACodec::getPortFormat.
Tools that made this possible: `debuggerd` is useless on this kernel (its worker times out; the waitpid patch only stops
the murder-suicide), so `crashpc` (ptrace + PTRACE_O_TRACECLONE, prints regs/stack/maps at SIGSEGV) located the crash;
`debug.ld.all=dlerror` shows the real dlopen error; `setprop debug.stagefright.omx-debug 5` traces OMX calls.
Known limit: the VPU buffers come from the 176 MB galcore pool; after many playbacks the pool can be exhausted
("_IOGetPhyMem: gpu allocator failed") until reboot.
