#!/bin/sh

CAMD_NAME="Camd3.908L"

echo $0 $1

remove_tmp () {
  rm -rf /tmp/*.info* /tmp/*.tmp* 2>/dev/null
}

case "$1" in
	start)
  remove_tmp
  /usr/bin/camd3.908L &
  ;;
	restart)
  killall -9 camd3.908L 2>/dev/null
  sleep 2
  remove_tmp
  /usr/bin/camd3.908L &
  ;;
	stop)
  kill 
  killall -9 camd3.908L 2>/dev/null
  sleep 2
  remove_tmp
  ;;
  *)
  $0 stop
  exit 0
  ;;
esac

exit 0
