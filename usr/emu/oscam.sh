#!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"
 
		echo "Activate Oscam."
		
		if [ ! -e /usr/bin/oscam ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/oscam.tar.gz && tar -xzvf oscam.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/oscam ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/oscam "
				fi
			rm -f oscam.tar.gz >> /tmp/install.log
			chmod 755 oscam >> /tmp/install.log
		else
			echo "oscam installed"
			echo ""
		fi
		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop
			sleep 3
		else
			echo "1 run"
		fi
			cp -f /etc/init.d/oscam_restart.sh /etc/rcS.d/S50emu
			echo "Oscam" > /etc/active_emu.list
			/etc/rcS.d/S50emu start  > /dev/null 2>&1

exit 0