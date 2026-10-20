# vendor/benesse/40S404 -- makefiles only, blobs are not included

`40S404-vendor.mk` / `40S404-omx.mk` install stock blobs through `PRODUCT_COPY_FILES` from `proprietary/`, which is absent in
this repository. Create it from the stock firmware of the same tablet:

    ./extract-files.sh            # tablet with stock ROM, root adb (or TWRP with /system mounted)
    ./extract-files.sh /path/to/stock    # directory containing the stock "system/" tree
    ./verify-files.sh             # sha256 check against proprietary-files.sha256

`proprietary-files.txt` is the original, commented list of what was taken from stock and why.

## Blobs that differ from stock (apply after extraction, `patchelf` >= 0.10)

* `lib/libtinyfsl.so` = the stock `/system/lib/libtinyalsa.so` (it exports `control_open`), installed under the name `libtinyfsl.so`
  (`extract-files.sh` does this copy).
* `hw/audio.primary.imx6.so`: `patchelf --replace-needed libtinyalsa.so libtinyfsl.so hw/audio.primary.imx6.so`
  (so the audio HAL uses the stock tinyalsa instead of the AOSP one).
* `hw/camera.imx6.so`: `patchelf --add-needed libjhead.so hw/camera.imx6.so` (the Lollipop+ linker only searches the direct
  dependencies of a dlopen()ed library).
