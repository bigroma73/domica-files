#!/bin/sh
#
BCKNAME=MyDailyBackup
#
wall "Cronmanager called Multiboot backup script"
echo "Backing up booted Image with Multiboot"
#
if [ -f /media/mb/multiboot.sh ]; then
/media/mb/multiboot.sh copy X B $BCKNAME
else
echo "Multiboot is not installed, sorry cann't backup "
ls -1alh /MB_Images/MB_$BCKNAME.tar.bz2
echo "Backup Done !"
fi
exit 0
