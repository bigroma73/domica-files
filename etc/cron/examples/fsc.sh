#!/bin/sh
wall "Cronmanager called reboot with Filesystemcheck script"
echo "Rebooting Dreambox with Forced Filesystemcheck - Good bye !"
shutdown -r -F now
exit 0
