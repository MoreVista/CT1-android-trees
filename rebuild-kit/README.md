# CM10.1 (Android 4.2.2) rebuild kit for the Benesse 40S404

The 92 GB CM10.1 build tree was deleted to free disk space. This kit + the repos in <your-dir>/ are
everything needed to rebuild it. Last good ROM: /mnt/hdd/40s404-rom-backups/cm10.1_20261005_final.zip (flash with TWRP).

## What is kept
- <your-dir>/android_device_benesse_40S404  (git; device tree, init rc, overlay, NOTES.md, patches/)
- <your-dir>/vendor_benesse_40S404          (git; stock blobs incl. FSL OMX/VPU)
- <your-dir>/android_device_benesse_40S404_kernel_zImage (stock kernel copy; prebuilt/zImage is in the device repo)
- this kit: manifests/ (default.xml + local_manifests + pinned-shas.txt = exact HEAD of every project),
  patches/ (frameworks/av, base, native diffs; sdk modifications; list of deleted sdk dirs), Dockerfile, build.sh
- docker images cm10.1-build:12.04 / ubuntu:12.04 live in /var/lib/docker (rebuild with Dockerfile.cm10.1-build-12.04 if gone:
  `docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t cm10.1-build:12.04 -f Dockerfile.cm10.1-build-12.04 .`)
- ccache moved to /mnt/hdd/ccache (shared by the CM11 / CM12.1 builds)

## Restore
1. mkdir -p /mnt/hdd/40s404-cm10.1/src && cd /mnt/hdd/40s404-cm10.1/src
2. repo init -u https://github.com/CyanogenMod/android.git -b cm-10.1 --depth=1
   cp -r <kit>/manifests/local_manifests .repo/   (removes platform/prebuilts/tools and platform/external/qemu)
   repo sync -c -j4 --no-clone-bundle --no-tags   (CyanogenMod GitHub org is archived; if a project is gone use pinned-shas.txt
   with the LineageOS mirror of the same name.)
   Optional: `git -C <path> checkout <sha>` from pinned-shas.txt to get the exact tree of the last build.
3. Apply patches:  git -C frameworks/av apply <kit>/patches/frameworks_av.patch   (same for base, native; sdk_modified.patch for sdk)
   Delete the sdk dirs listed in patches/sdk_deleted_toplevel_dirs.txt (or the files in sdk_deleted_files.txt) - the
   Eclipse/ADT/hierarchyviewer tooling that does not build.
4. bash <kit>/build.sh 'mka bacon'  -> out/target/product/40S404/cm-10.1-*.zip
