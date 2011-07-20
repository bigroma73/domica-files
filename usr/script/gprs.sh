#!/bin/sh

DEVICE=ppp0
set -e

case "$1" in
    start)
	/usr/sbin/pppd call gprs-siem &
	exit 0
	;;
    stop)
if [ -r /var/run/$DEVICE.pid ]; then
        kill -INT `cat /var/run/$DEVICE.pid`

        if [ ! "$?" = "0" ]; then
                rm -f /var/run/$DEVICE.pid
                echo "ERROR: Removed stale pid file"
                exit 1
        fi
        echo "PPP link to $DEVICE terminated!"
        echo "GPRS connection closed!"
        exit 0
fi


	rm -f /var/lock/LCK*
	exit 0
	;;
    *)
	echo "Usage: $0 {start|stop}"
	exit 1
	;;
esac

exit 0
