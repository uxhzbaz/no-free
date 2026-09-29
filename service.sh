until [ `getprop sys.boot_completed` ];do sleep 5;done
sleep 20;sh ${0%/*}/no-free.sh
