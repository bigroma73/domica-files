 #!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"

       	echo "Activate Newcs+Mgcamd."

		if [ ! -e /usr/bin/mgcamd_1.35a ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/mgcamd_1.35a.tar.gz && tar -xzvf mgcamd_1.35a.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/mgcamd_1.35a ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/mgcamd_1.35a "
				fi
			rm -f mgcamd_1.35a.tar.gz >> /tmp/install.log
			chmod 755 mgcamd_1.35a >> /tmp/install.log
		else
			echo "mgcamd installed"
			echo ""
		fi
		if [ ! -e /usr/bin/newcs_1.67 ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/newcs_1.67.tar.gz && tar -xzvf newcs_1.67.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/newcs_1.67 ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/newcs_1.67 "
				fi
			rm -f newcs_1.67.tar.gz >> /tmp/install.log
			chmod 755 newcs_1.67
		else
			echo "newcs installed"
			echo ""
		fi
		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop
			sleep 3
		else
			echo "1 run"
		fi
		cp -f /etc/init.d/mgcamd_newcs_restart.sh /etc/rcS.d/S50emu
		echo "Newcs+Mgcamd" > /etc/active_emu.list
		/etc/rcS.d/S50emu start  > /dev/null 2>&1

exit 0
