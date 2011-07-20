#!/bin/sh

CAMNAME="MgCamd 1.35a/OScam 0.99.4"
USERNAME="MgCamd² 1.35a/OScam 0.99.4"
# end

remove_tmp () {
  rm -rf /tmp/*.info* /tmp/*.tmp* /tmp/*mgcamd* /tmp/*.log 2>/dev/null
}

case "$1" in
  start)
  echo "[SCRIPT] $1: $CAMNAME"
  remove_tmp
  /usr/bin/oscam &
  sleep 4 
  /usr/bin/mgcamd_1.35a &
  ;;
  restart)
  echo "[SCRIPT] $1: $CAMNAME"
  killall -9 mgcamd_1.35a oscam 2>/dev/null
  remove_tmp
  /usr/bin/oscam &
  sleep 4 
  /usr/bin/mgcamd_1.35a &
  ;;
  stop)
  echo "[SCRIPT] $1: $CAMNAME"
  killall -9 mgcamd_1.35a oscam 2>/dev/null
  remove_tmp
  ;;
  *)
  $0 stop
  exit 0
  ;;
esac

exit 0
