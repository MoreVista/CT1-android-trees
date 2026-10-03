#!/system/bin/sh
# Marvell sd8787: the SDIO probe fails on the first insmod after boot unless the
# chip is power-cycled first (wifi_reset.0 gpio), so reset, then load with the
# same parameters the stock init.rc uses, wait for wlan0, then run mlaninit.
RST=/sys/devices/platform/wifi_reset.0/wifi_reset
echo 0 > $RST
echo 1 > $RST
sleep 2
insmod /system/etc/wifi/mlan.ko
insmod /system/etc/wifi/sd8787.ko drv_mode=1 cfg80211_wext=4 sta_name=wlan
i=0
while [ ! -d /sys/class/net/wlan0 ] && [ $i -lt 20 ]; do
    sleep 1
    i=$((i+1))
done
/system/bin/mlaninit.sh
