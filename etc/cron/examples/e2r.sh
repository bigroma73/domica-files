#!/bin/sh
echo "Checking for enigma reload from WebIF"
if [ -f /usr/lib/enigma2/python/Plugins/Extensions/ER/reload_sheduled ]; then
   echo "Restarting enigma"
   init 2
   init 3
   rm /usr/lib/enigma2/python/Plugins/Extensions/ER/reload_sheduled
else
   echo "Nothing to be done"
fi
exit 0
