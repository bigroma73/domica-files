#!/bin/sh
clear
if [ -e /tmp/minicat ]; then
echo "deleting folder minicat now, please wait..."
rm -rf /tmp/minicat
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
wget http://cori1.homeip.net -O /tmp/minicat.tar.gz 
echo "installing keys now, please wait..."
mkdir /tmp/minicat
tar -xzf /tmp/minicat.tar.gz -C /tmp/minicat/
rm -rf /etc/keys/nagra_roms
mv -f /tmp/minicat/var/keys/* /etc/keys/
mv -f /tmp/minicat/var/scce/* /etc/scce/
cd /tmp
echo "deleting temporary files now..."
rm -rf /tmp/minicat/*
rm -rf /tmp/minicat
rm -rf /tmp/minicat.tar.gz
echo "key-update procedur finished, HAVE FUN NOW..."
KeyDate=`/bin/date -r /etc/keys/SoftCam.Key +%d.%m.%y-%H:%M:%S`
	echo ""
	echo "Date of the bundle: $KeyDate"
	echo ""
sleep 2
exit 0
