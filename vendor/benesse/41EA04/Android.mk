LOCAL_PATH := $(call my-dir)

ifneq ($(filter 41EA04,$(TARGET_DEVICE)),)
  include $(call all-makefiles-under,$(LOCAL_PATH))
endif
