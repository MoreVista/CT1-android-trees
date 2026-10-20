LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := sftest
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := sftest.cpp
LOCAL_SHARED_LIBRARIES := libgui libui libutils libcutils libEGL libGLESv2 libbinder liblog
LOCAL_CFLAGS := -Wno-unused-parameter
include $(BUILD_EXECUTABLE)
