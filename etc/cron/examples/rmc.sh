#!/bin/sh
wall "Cronmanager called enigma crash cleaning script"
echo "Cleaning enigma crash dumps at /media/hdd"
rm /media/hdd/enigma2_crash*
echo "Cleaning Done !"
exit 0
