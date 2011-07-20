 #!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"

		echo "Activate CCcam."

		if [ ! -e /usr/bin/CCcam_2.1.4 ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/CCcam_2.1.4.tar.gz && tar -xzvf CCcam_2.1.4.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/CCcam_2.1.4 ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/CCcam_2.1.4 "
				fi
			rm -f CCcam_2.1.4.tar.gz >> /tmp/install.log
			chmod 755 CCcam_2.1.4
		else
			echo "CCcamd installed"
			echo ""
		fi
		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop
			sleep 3
		else
			echo "1 run"
		fi
		cp -f /etc/init.d/cccam_restart.sh /etc/rcS.d/S50emu
		echo "CCcam_2.1.4" > /etc/active_emu.list
		/etc/rcS.d/S50emu start  > /dev/null 2>&1

exit 0
