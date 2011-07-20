#!/bin/sh

/usr/script/gprs.sh stop
route add default gw `cat /tmp/gate`
exit 0
