#!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"

		echo "Activate Hypercam."

		if [ ! -e /usr/bin/hypercam_2.06 ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/hypercam.tar.gz && tar -xzvf hypercam.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/hypercam_2.06 ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/hypercam_2.06 "
				fi
			rm -f hypercam.tar.gz >> /tmp/install.log
			chmod 755 hypercam_2.06
			chmod 644 hypercam.keys
			chmod 644 hypercam.cfg
		else
			echo "Hypercam installed"
			echo ""
		fi
		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop
			sleep 3
		else
			echo "first run"
		fi
		cp -f /etc/init.d/hypercam_restart.sh /etc/rcS.d/S50emu
		echo "Hypercam" > /etc/active_emu.list
		/etc/rcS.d/S50emu start  > /dev/null 2>&1

exit 0
