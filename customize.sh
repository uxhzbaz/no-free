E=$MODPATH/system/etc
mkdir -p $E
[ -s /sdcard/hosts ]&&cp /sdcard/hosts $E/||cp /system/etc/hosts $E/
