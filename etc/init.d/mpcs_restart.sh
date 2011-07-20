#!/bin/sh

CAMNAME="MPCS² 16f"

case "$1" in
	start)
	echo "[SCRIPT] $1: $CAMNAME"
	/usr/bin/mpcs_16f &
	;;
	restart)
	echo "[SCRIPT] $1: $CAMNAME"
	killall -9 mpcs_16f 2>/dev/null
	/usr/bin/mpcs_16f &
	;;
	stop)
	echo "[SCRIPT] $1: $CAMNAME"
	killall -9 mpcs_16f 2>/dev/null
	;;
	*)
	$0 stop
	exit 0
	;;
esac

exit 0
