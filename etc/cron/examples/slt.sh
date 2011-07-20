#!/bin/sh
wall "Cronmanager called Shutdown script"
echo "Shutting Dreambox down with HALT - Good bye !"
if [ -f /bin/enigma ]; then
halt
#reboot
else
shutdown -h now
#shutdown -r now
fi
exit 0
