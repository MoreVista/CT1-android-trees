# Stub for the "guava-tools" host Java library. The real one normally ships
# inside platform/prebuilts/tools (Eclipse/ADT), which this build excludes
# (see .repo/local_manifests/remove_unneeded.xml -- that project repeatedly
# caused multi-tens-of-GB runaway fetches). "common"/CTS tradefed tooling
# depends on it transitively even for a plain mka bacon, so stub it with the
# same-generation guava jar already present at prebuilts/sdk/tools/lib.
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := guava-tools
LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_IS_HOST_MODULE := true
LOCAL_SRC_FILES := guava-tools.jar
include $(BUILD_PREBUILT)
