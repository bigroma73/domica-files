#!/bin/sh
CAMNAME="Mgcamd_1.35a"

remove_tmp () {
rm -rf /tmp/*.info* /tmp/*.tmp* /tmp/*mgcamd* 2>/dev/null
}

case "$1" in
start)
echo "[SCRIPT] $1: $CAMNAME"
remove_tmp
/usr/bin/mgcamd_1.35a &
;;
stop)
echo "[SCRIPT] $1: $CAMNAME"
killall -9 mgcamd_1.35a 2>/dev/null
remove_tmp
;;
restart)
echo "[SCRIPT] $1: $CAMNAME"
killall -9 mgcamd_1.35a 2>/dev/null
remove_tmp
/usr/bin/mgcamd_1.35a &
;;
*)
$0 stop
exit 0
;;
esac

exit 0
