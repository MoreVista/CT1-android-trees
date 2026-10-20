#!/bin/bash
# Populate ./proprietary from the STOCK firmware of the tablet (the blobs are not part of this repository).
#
#   ./extract-files.sh            # adb pull from a tablet that is running the stock Benesse ROM (needs root adb,
#                                 # or boot TWRP and `mount /system` first)
#   ./extract-files.sh DIR        # copy from a directory that contains the stock "system/" tree
#                                 # (e.g. an unpacked stock system.img or a TWRP backup)
#
# The list of files is taken from the PRODUCT_COPY_FILES lines of the *.mk files next to this script.
# Afterwards run ./verify-files.sh: proprietary-files.sha256 holds the checksums of the files exactly as they were used
# for the ROM -- files marked "(modified)" in README.md differ from stock and need the patchelf step listed there.
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
SRC=${1:-}
grep -hoE 'proprietary/[^ :\\]+:system/[^ \\]+' "$DIR"/*.mk | sort -u | while IFS=: read -r rel dest; do
    out="$DIR/$rel"
    mkdir -p "$(dirname "$out")"
    from="$dest"
    # libtinyfsl.so is the stock libtinyalsa.so (it has control_open) installed under a different name, see README.md
    [ "$dest" = "system/lib/libtinyfsl.so" ] && from="system/lib/libtinyalsa.so"
    if [ -n "$SRC" ]; then
        cp -f "$SRC/$from" "$out" || echo "WARNING: missing $from"
    else
        adb pull "/$from" "$out" >/dev/null || echo "WARNING: could not pull /$from"
    fi
    echo "extracted $rel"
done
echo "done. Now apply the binary modifications from README.md, then run ./verify-files.sh"
