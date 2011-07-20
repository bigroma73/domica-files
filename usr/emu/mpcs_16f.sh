 #!/bin/sh

echo "<<=====================================>>"
echo "<<=========== DOMICA IMAGE ============>>"
echo "<<=====================================>>"

		echo "Activate Mpcs."
		
		if [ ! -e /usr/bin/mpcs_16f ]; then
			cd /usr/bin
			wget http://www.upload.metabox.ru/dm800/mpcs_16f.tar.gz && tar -xzvf mpcs_16f.tar.gz >> /tmp/install.log
				 if [ ! -e /usr/bin/mpcs_16f ]; then
					 echo " Download failed. Check internet connection or copy manualy binary file /usr/bin/mpcs_16f "
				fi
			rm -f mpcs_16f.tar.gz >> /tmp/install.log
			chmod 755 mpcs_16f >> /tmp/install.log
		else
			echo "mpcs installed"
			echo ""
		fi
		if [ -e /etc/rcS.d/S50emu ]; then
			/etc/rcS.d/S50emu stop
			sleep 3
		else
			echo "1 run"
		fi
			cp -f /etc/init.d/mpcs_restart.sh /etc/rcS.d/S50emu
			echo "Mpcs_16f" > /etc/active_emu.list
			/etc/rcS.d/S50emu start  > /dev/null 2>&1
exit 0
