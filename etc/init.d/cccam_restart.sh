#!/bin/sh

remove_tmp () {
  rm -rf /tmp/*.info* /tmp/*.tmp* 2>/dev/null
}

case "$1" in
  start)
  echo "start CCcam² 2.1.4"
  remove_tmp
  /usr/bin/CCcam_2.1.4 &
  ;;
  stop)
  echo "start CCcam² 2.1.4"
  killall -9 CCcam_2.1.4 2>/dev/null
  sleep 2
  remove_tmp
  ;;
  restart)
  echo "restart CCcam² 2.1.4"
  killall -9 CCcam_2.1.4 2>/dev/null
  sleep 2
  remove_tmp
  /usr/bin/CCcam_2.1.4 &
  ;;
  *)
  $0 stop
  exit 0
  ;;
esac

exit 0
