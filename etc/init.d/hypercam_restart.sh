#!/bin/sh

logger $0 $1
echo $0 $1

remove_tmp () {
  rm -rf /tmp/*.info* /tmp/*.tmp*
}

case "$1" in
  start)
  remove_tmp
  /usr/bin/hypercam_2.06 &
  ;;
  stop)
  killall -9 hypercam_2.06 2>/dev/null
  sleep 2
  remove_tmp
  ;;
  restart)
  killall -9 hypercam_2.06 2>/dev/null
  sleep 2
  remove_tmp
  /usr/bin/hypercam_2.06 &
  ;;
  *)
  $0 stop
  exit 0
  ;;
esac

exit 0
