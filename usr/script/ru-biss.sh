#!/bin/sh
		if [ ! -e /etc/keys/my_biss.Key ]; then
			cd /etc/keys
			wget http://www.upload.metabox.ru/dm800/my_biss.Key
		fi
mv /etc/keys/SoftCam.Key /tmp/SoftCam.Key
cat /etc/keys/my_biss.Key /tmp/SoftCam.Key > /etc/keys/SoftCam.Key

echo "All keys BISS updated in Softcam.key"

exit 0