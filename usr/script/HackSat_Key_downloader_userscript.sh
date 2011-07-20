#!/bin/sh
echo ""
echo "HackSat_Key_Downloader"
echo "Downloading Keys..."
cd /tmp
#keys 
wget http://www.uydu.ws/deneme6.php?file=SoftCam.Key -O /tmp/SoftCam.Key
wget http://www.uydu.ws/deneme6.php?file=softcam.cfg -O /tmp/softcam.cfg
wget http://www.uydu.ws/deneme6.php?file=nagra -O /tmp/nagra
wget http://www.uydu.ws/deneme6.php?file=AutoRoll.Key -O /tmp/AutoRoll.Key
wget http://www.uydu.ws/deneme6.php?file=constant.cw -O /tmp/constant.cw
wget http://www.uydu.ws/deneme6.php?file=tps.au -O /tmp/tps.au
wget http://www.uydu.ws/deneme6.php?file=camd3.keys -O /tmp/camd3.keys
#scce
wget http://www.uydu.ws/deneme6.php?file=keylist -O /tmp/keylist
wget http://www.uydu.ws/deneme6.php?file=rsakeylist -O /tmp/rsakeylist
wget http://www.uydu.ws/deneme6.php?file=constantcw -O /tmp/constantcw
#wget http://www.skystar.org/arsiv/dailytps/tps.au -O /tmp/tps.au
#wget http://www.skystar.org/arsiv/dailytps/tps.bin -O /tmp/tps.bin
echo "______________________________"
find /tmp/SoftCam.Key
find /tmp/softcam.cfg
find /tmp/nagra
find /tmp/AutoRoll.Key
find /tmp/constant.cw
find /tmp/tps.au
find /tmp/camd3.keys
find /tmp/keylist
find /tmp/rsakeylist
find /tmp/constantcw
echo ""
chmod 644 /tmp/SoftCam.Key
chmod 755 /tmp/softcam.cfg
chmod 644 /tmp/nagra
chmod 644 /tmp/AutoRoll.Key
chmod 644 /tmp/constant.cw
chmod 0 /tmp/tps.au
chmod 644 /tmp/camd3.keys
chmod 644 /tmp/keylist
chmod 644 /tmp/rsakeylist
chmod 644 /tmp/constantcw
echo ""
cp SoftCam.Key /etc/keys/
cp softcam.cfg /etc/keys/
cp nagra /etc/keys/
cp AutoRoll.Key /etc/keys/
cp constant.cw /etc/keys/
cp tps.au /etc/keys/
cp camd3.keys /etc/keys/
cp keylist /etc/scce/
cp rsakeylist /etc/scce/
cp constantcw /etc/scce/
echo ""
rm -rf /tmp/SoftCam.Key
rm -rf /tmp/softcam.cfg
rm -rf /tmp/nagra
rm -rf /tmp/AutoRoll.Key
rm -rf /tmp/constant.cw
rm -rf /tmp/tps.au
rm -rf /tmp/camd3.keys
rm -rf /tmp/keylist
rm -rf /tmp/rsakeylist
rm -rf /tmp/constantcw
echo "______________________________"
echo "All keys Updated ."
echo "______________________________"
sleep 2
exit 0