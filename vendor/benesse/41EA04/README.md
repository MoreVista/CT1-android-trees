# vendor/benesse/41EA04 -- makefiles only, blobs are not included

`41EA04-vendor.mk` / `41EA04-omx.mk` install stock blobs through `PRODUCT_COPY_FILES` from `proprietary/`, which is absent in
this repository. Create it from the stock firmware of the same tablet:

    ./extract-files.sh            # tablet with stock ROM, root adb (or TWRP with /system mounted)
    ./extract-files.sh /path/to/stock    # directory containing the stock "system/" tree
    ./verify-files.sh             # sha256 check against proprietary-files.sha256

`proprietary-files.txt` is the original, commented list of what was taken from stock and why.

## Blobs that differ from stock (apply after extraction, `patchelf` >= 0.10)

Same modifications as `vendor/benesse/40S404/README.md` (`libtinyfsl.so`, `audio.primary.imx6.so`). Extract from the stock firmware of the **41EA04** itself, its blobs/kernel differ.
