#!/bin/sh

echo `route |grep default |awk '{print $2}'` > /tmp/gate
/usr/script/gprs.sh start

exit 0
