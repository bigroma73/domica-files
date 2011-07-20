#!/bin/sh

CAMNAME="MgCamd 1.35a/NewCS 1.67"
USERNAME="MgCamd² 1.35a/NewCS² 1.67"
CAMID=4299
START_TIME=4
STOPP_TIME=2
INFOFILE="ecm.info"
INFOFILELINES=
# end

remove_tmp () {
  rm -rf /tmp/*.info* /tmp/*.tmp* /tmp/*mgcamd* 2>/dev/null
}

case "$1" in
  start)
  echo "[SCRIPT] $1: $CAMNAME"
  remove_tmp
  /usr/bin/newcs_1.67 &
  sleep 15 
  /usr/bin/mgcamd_1.35a &
  ;;
  restart)
  echo "[SCRIPT] $1: $CAMNAME"
  killall -9 mgcamd_1.35a newcs_1.67 2>/dev/null
  remove_tmp
  /usr/bin/newcs_1.67 &
  sleep 15 
  /usr/bin/mgcamd_1.35a &
  ;;
  stop)
  echo "[SCRIPT] $1: $CAMNAME"
  killall -9 mgcamd_1.35a newcs_1.67 2>/dev/null
  remove_tmp
  ;;
  *)
  $0 stop
  exit 0
  ;;
esac

exit 0
