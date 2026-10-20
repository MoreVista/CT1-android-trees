LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_PACKAGE_NAME := TexTest
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := src/org/tt/Main.java
LOCAL_SDK_VERSION := current
LOCAL_PROGUARD_ENABLED := disabled
include $(BUILD_PACKAGE)
