#!/bin/sh

CAMNAME="Oscam 0.99.4"

case "$1" in
	start)
	echo "[SCRIPT] $1: $CAMNAME"
	/usr/bin/oscam &
	;;
	restart)
	echo "[SCRIPT] $1: $CAMNAME"
	killall -9 oscam 2>/dev/null
	/usr/bin/oscam &
	;;
	stop)
	echo "[SCRIPT] $1: $CAMNAME"
	killall -9 oscam 2>/dev/null
	;;
	*)
	$0 stop
	exit 0
	;;
esac

exit 0
