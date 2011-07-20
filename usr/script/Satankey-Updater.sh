#!/bin/sh
clear
if [ -e /tmp/satan ]; then
echo "deleting folder satan now, please wait..."
rm -rf /tmp/satan
fi
if [ ! -e /etc/keys ]; then
echo "creating keys now, please wait..."
mkdir /etc/keys
fi
if [ ! -e /etc/scce ]; then
echo "creating folder scce now, please wait..."
mkdir /etc/scce
fi
echo "downloading needet keys now, please wait..."
wget http://cori.homeip.net -O /tmp/satan.tar.gz
echo "installing keys now, please wait..."
mkdir /tmp/satan
tar -xzf /tmp/satan.tar.gz -C /tmp/satan/
rm -rf /etc/keys/nagra_roms
mv -f /tmp/satan/var/keys/* /etc/keys/
mv -f /tmp/satan/var/scce/* /etc/scce/
cd /tmp
echo "deleting temporary files now..."
rm -rf /tmp/satan/*
rm -rf /tmp/satan
rm -rf /tmp/satan.tar.gz
echo "key-update procedur finished, HAVE FUN NOW..."
KeyDate=`/bin/date -r /etc/keys/SoftCam.Key +%d.%m.%y-%H:%M:%S`
	echo ""
	echo "Date of the bundle: $KeyDate"
	echo ""
sleep 2
exit 0
