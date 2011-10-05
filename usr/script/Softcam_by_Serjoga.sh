#!/bin/sh
clear
if [ -e /tmp/softcam ]; then
echo "deleting folder satan now, please wait..."
rm -rf /tmp/softcam
fi
if [ ! -e /var/keys ]; then
echo "creating keys now, please wait..."
mkdir /var/keys
fi
echo "downloading softcam by Serjoga now, please wait..."
wget http://www.sikais1983.chat.ru/SoftCam.zip -O /tmp/SoftCam.zip
echo "installing softcam now, please wait..."
mkdir /tmp/softcam
unzip  /tmp/SoftCam.zip -d /tmp/softcam
rm -rf /var/keys/SoftCam.key
mv -f /tmp/softcam/* /var/keys/
cd /tmp
echo "deleting temporary files now..."
rm -rf /tmp/softcam/*
rm -rf /tmp/softcam
rm -rf /tmp/SoftCam.zip
echo "key-update procedur finished, HAVE FUN NOW..."
KeyDate=`/bin/date -r /var/keys/SoftCam.Key +%d.%m.%y-%H:%M:%S`
	echo ""
	echo "Date of the bundle: $KeyDate"
	echo ""
sleep 2
exit 0
