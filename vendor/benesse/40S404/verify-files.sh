#!/bin/bash
# Compare ./proprietary with proprietary-files.sha256 (checksums of the blobs as used by the ROM).
cd "$(dirname "$0")" && sha256sum -c --quiet --ignore-missing proprietary-files.sha256 && echo "all blobs match"
