LOCAL_PATH := $(call my-dir)

ifneq ($(filter 40S404,$(TARGET_DEVICE)),)
  include $(call all-makefiles-under,$(LOCAL_PATH))
endif
