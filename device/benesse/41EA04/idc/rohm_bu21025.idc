touch.deviceType = touchScreen
touch.orientationAware = 1

touch.size.calibration = none
touch.orientation.calibration = none

# Real digitizer range (measured on the unit); the driver declares 0-1024 x 0-768.
# Handled by the EventHub idc override patch (patches/frameworks_base-EventHub-idc-abs-range.patch).
abs.0.min = 40
abs.0.max = 936
abs.1.min = 70
abs.1.max = 732
