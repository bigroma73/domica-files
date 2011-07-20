#!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"
echo " "

		echo "Activate camd3."
		if [ ! -e /usr/bin/camd3.908L ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/camd3.908L.tar.gz && tar -xzvf camd3.908L.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/camd3.908L ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/camd3.908L "
				fi
			rm -f camd3.908L.tar.gz >> /tmp/install.log
			chmod 755 camd3.908L
		fi

		if [ ! -e /usr/bin/pcamd ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/pcamd.tar.gz && tar -xzvf pcamd.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/pcamd]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/pcamd "
				fi
			rm -f pcamd.tar.gz >> /tmp/install.log
			chmod 755 pcamd
		fi

		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop && echo "softcam stop" || echo "need reboot"
			sleep 3
		else
			echo "Have not active softcam"
		fi
			cp -f /etc/init.d/camd3_restart.sh /etc/rcS.d/S50emu
			echo "Camd3.908L" > /etc/active_emu.list
			/etc/rcS.d/S50emu start  > /dev/null 2>&1

exit 0
