# CM10.1 build (Android 4.2.2) for the 40S404. Run after "Restore" in README.md.
# $1 = make command, e.g. 'mka bacon'
SRC=/mnt/hdd/40s404-cm10.1/src
cd $SRC
docker run --rm -u $(id -u):$(id -g) \
  -v $SRC:/src \
  -v /home/endo/40s404-cm10.1/android_device_benesse_40S404:/src/device/benesse/40S404 \
  -v /home/endo/40s404-cm10.1/vendor_benesse_40S404:/src/vendor/benesse/40S404 \
  -v /mnt/hdd/ccache:/ccache -w /src cm10.1-build:12.04 \
  bash -lc "export USE_CCACHE=1 CCACHE_DIR=/ccache; source build/envsetup.sh >/dev/null; lunch cm_40S404-userdebug >/dev/null; $1"
