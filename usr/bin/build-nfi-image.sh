#!/bin/sh
# based on IHAD script.
VSNDMAN=$3 
DIRECTORY=$1
MTDBOOT=2
MTDROOT=3
SWAPSIZE=$2
if [ "$SWAPSIZE" -lt 1 ]; then
SWAPSIZE=128
fi

if grep -qs 7020 /proc/bus/dreambox ; then
	BOXTYPE=dm7020
	OPTIONS="--eraseblock=0x4000 -n -b"
elif grep -qs DM600PVR /proc/bus/dreambox ; then
	BOXTYPE=dm600pvr
	OPTIONS="--eraseblock=0x4000 -n -b"
elif grep -qs DM500PLUS /proc/bus/dreambox ; then
	BOXTYPE=dm500plus
	OPTIONS="--eraseblock=0x4000 -n -b"
elif grep -qs 'ATI XILLEON HDTV SUPERTOLL' /proc/cpuinfo ; then
	BOXTYPE=dm7025
	OPTIONS="--eraseblock=0x4000 -n -l"
elif grep -qs 'dm8000' /proc/stb/info/model ; then
	BOXTYPE=dm8000
	OPTIONS="--eraseblock=0x20000 -n -l"
elif grep -qs 'dm800' /proc/stb/info/model ; then
	BOXTYPE=dm800
	OPTIONS="--eraseblock=0x4000 -n -l"
elif grep -qs 'dm800se' /proc/stb/info/model ; then
	BOXTYPE=dm800se
	OPTIONS="--eraseblock=0x4000 -n -l"
elif grep -qs 'dm500hd' /proc/stb/info/model ; then
	BOXTYPE=dm500hd
	OPTIONS="--eraseblock=0x4000 -n -l"
else
	echo "No supported Dreambox found!!!"
	exit 0
fi

echo " "
echo "*********************"
echo "** $BOXTYPE found **"
echo "*********************"
echo " "

echo "---------------------------------------------------------------"

listdummy=ls "$DIRECTORY"/blabla 2> /dev/null
FREESIZE=`df -m "$DIRECTORY" | tr -s " " | tail -n1 | cut -d' ' -f4 | sed "s/Available/0/`
if ! [ "$FREESIZE" -gt "128" ]; then
	echo ""$DIRECTORY" can't be used for FlashBackup because there is too less space left on the device!"
	echo "trying to find an alternative medium"
echo "---------------------------------------------------------------"
	DEVICE=`df -m | grep / | awk '{print $4 " " $1}' | sort -n | cut -d ' ' -f2 | tail -n1`
	DIRECTORY=`mount | grep $DEVICE | sort -n | cut -d ' ' -f3`
	FREESIZE=`df -m | grep / | awk '{print $4 " " $1}' | sort -n | cut -d ' ' -f1 | tail -n1`
	if [ "$FREESIZE" -lt "128" ]; then
		echo "No laternative medium could be found"
		echo "probably no correct medium is mounted"
		echo "---------------------------------------------------------------"
		exit 0
	else
		echo "Alternative medium=$DIRECTORY"
echo "---------------------------------------------------------------"
	fi
fi


echo "check if 128MB are free in $DIRECTORY"
if [ "$FREESIZE" -lt "128" ]; then
		echo "Free memory space="$FREESIZE"MB,aborting FlashBackup"
		echo "---------------------------------------------------------------"
		exit 0
	else
		echo "Free memory space="$FREESIZE"MB=OK"
		SWAPDIR=$DIRECTORY/backup/FlashBackup
		SSLDIR=$DIRECTORY/backup/FlashBackup/SSL
		mkdir -p $SSLDIR
		echo "---------------------------------------------------------------"
fi


if ! test -z "$VSNDMAN" -o -n "`echo \"$VSNDMAN\" | tr -d '[0-9]'`" ; then
  echo "Secondstageloader-version manually set to $VSNDMAN"
  VSND=$VSNDMAN
else

  	echo "Trying to find secondstageloader-version in Ipkg-List"
  VSND=`ipkg list | grep dreambox-secondstage | cut -d' ' -f3 |cut -d'-' -f1 | tail -n 1`

  if test -z "$VSND" -o -n "`echo \"$VSND\" | tr -d '[0-9]'`" ; then
    echo "No secondstageloader-version in Ipkg-List found :("

    echo "Trying to get the latest secondstageloader-version from IHAD"   
    wget -q http://www.i-have-a-dreambox.com/diverses/secondstageloader/$BOXTYPE -O /tmp/SSLs > /dev/null
    IHADSSL=`cat /tmp/SSLs | grep secondstage | cut -d'-' -f3 |cut -d'.' -f1 | tail -n 1`
    
    SearchSSL=`expr $IHADSSL "+" 5`
    echo "Trying to find newer secondstageloader-version than "$IHADSSL" at Dreamboxupdate..."
    wget -q http://www.dreamboxupdate.com/download/7020/secondstage-$BOXTYPE-$IHADSSL.bin -O $SSLDIR/secondstage-$BOXTYPE-$IHADSSL.bin 2> /dev/null
    IHADSSL=`expr $IHADSSL "+" 1`
     while [ $IHADSSL -lt $SearchSSL ] ; do
      echo "- Starting search for secondstageloader-version $IHADSSL... -"
      wget -q http://www.dreamboxupdate.com/download/7020/secondstage-$BOXTYPE-$IHADSSL.bin -O $SSLDIR/secondstage-$BOXTYPE-$IHADSSL.bin 2> /dev/null
     IHADSSL=`expr $IHADSSL "+" 1`
    done
   rm -rf /tmp/SSLs
   VSND=`find $SSLDIR -name "secondstage-$BOXTYPE-*.bin" | cut -d"-" -f3 | cut -d"." -f1 | sort -n | tail -n 1`
  else
    echo "Secondstageloader-version found in Ipkg-List"
fi

if test -z "$VSND" -o -n "`echo \"$VSND\" | tr -d '[0-9]'`" ; then
  echo "**************************************************************************************"
  echo "* Secondstageloader couldn't be found. Either your box is offline, or you don't have *"
  echo "* any secondstageloader in $SSLDIR. For an offline-backup you have to download       *"       
  echo "* the secondstageloader.bin and the *.bin.md5 and move it to $SSLDIR.                *"
  echo "* You can find your secondstageloader here:                                          *"
  echo "* Download www.i-have-a-dreambox.com/diverses/secondstageloader/$BOXTYPE             *"
  echo "**************************************************************************************"
  exit 0
else
	echo "-------------------------------------------------------------------"
        echo "Secondstageloader-version "$VSND" will be used for FlashBackup     "
	echo "-------------------------------------------------------------------"


if [ $BOXTYPE = "dm8000" -o $BOXTYPE = "dm800" -o $BOXTYPE = "dm7025" -o $BOXTYPE = "dm800se" -o $BOXTYPE = "dm500hd" ] ;then
	echo "Trying to identify flash-image"
	if grep -qs "url=http:\/\/www.i-have-a-dreambox.com" /etc/image-version ; then
		IMAGEINFO=Gemini-`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{3\}\)$/\1/' | cut -b 1`.`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{2\}\)$/\1/'` # sed Befehl schnappt sich die letzten 3 Zeichen
		echo "$IMAGEINFO found"
	elif [ `cat /etc/image-version | grep creator | sed "s/creator=//" | cut -d " " -f 1` = "Pashaa" ] ; then
		IMAGEINFO=DOMICA-image
		echo "$IMAGEINFO found"
	elif [ `cat /etc/image-version | grep creator | sed "s/creator=//" | cut -d " " -f 1` = "newnigma2" ] ; then
		IMAGEINFO=Newnigma2
		echo "$IMAGEINFO found"
	elif [ `cat /etc/image-version | grep creator | sed "s/creator=//" | cut -d " " -f 1` = "LT" ] ; then
		IMAGEINFO=LT-Team
		echo "$IMAGEINFO found"
	elif [ `cat /etc/image-version | grep creator | sed "s/creator=//" | cut -d " " -f 1` = "MiLo" ] ; then
		IMAGEINFO=MiLo
		echo "$IMAGEINFO found"
	else
		IMAGEINFO=backup
		echo "Couldn't identify flash-image, using backup as backupname"
	fi
else
	IMAGEINFO=backup
	echo "Couldn't identify flash-image, using backup as backupname"
fi
	echo "---------------------------------------------------------------"
DATE=`date +%Y-%m-%d@%H.%M.%S`
MKFS=/usr/bin/mkfs.jffs2
BUILDIMAGE=/usr/bin/buildimage
BACKUPIMAGE=$SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfi
SND=secondstage-$BOXTYPE-$VSND.bin

if [ ! -f $MKFS ] ; then
	echo $MKFS" not found in /usr/bin :("
	exit 0
fi
if [ ! -f $BUILDIMAGE ] ; then
	echo $BUILDIMAGE" not found in /usr/bin :("
	exit 0
fi

mkdir -p $SSLDIR
if [ -f $SSLDIR/$SND ] ; then
  cp -r $SSLDIR/$SND /tmp/secondstage.bin 2> /dev/null
  echo "Secondstageloader found in $SSLDIR ,use $SND"
else
  echo "...Download" $SND
  wget -q http://sources.dreamboxupdate.com/download/7020/$SND -O $SSLDIR/$SND > /dev/null

	if [ -f $SSLDIR/$SND ] ; then
		cp -r $SSLDIR/$SND /tmp/secondstage.bin 2> /dev/null
	else
		echo ""
		echo "##############################################################"
		echo "# "$SND" couldn't be downloaded #"
		echo "# maybe your Box or dreamboxupdate.com is offline    #"
		echo "##############################################################"
		echo ""
		exit 0
	fi
fi


	if ! [ -f $SSLDIR/$SND.md5 ] ; then
		echo "...Download" $SND.md5
		wget -q http://www.i-have-a-dreambox.com/diverses/secondstageloader/$BOXTYPE/$SND.md5 -O $SSLDIR/$SND.md5 > /dev/null
	fi
echo "---------------------------------------------------------------"

	if [ -f $SSLDIR/$SND.md5 ] ; then
		md5sum $SSLDIR/$SND > /tmp/SSL.md5
		#md5sum -c MD5SUM
		if [ `cat /tmp/SSL.md5 | cut -d' ' -f1` = `cat $SSLDIR/$SND.md5 | cut -d' ' -f1` ] ; then 
			echo "MD5 check=OK"
			rm -r /tmp/SSL.md5
		else
			echo " "
			echo "##################################"
			echo "# MD5 chech failed!              #"
			echo "# please run FlashBackup         #"
			echo "# once again                     #"
			echo "##################################"
			echo " "
			rm -r /tmp/SSL.md5
			rm -r $SSLDIR/$SND.md5
			rm -r $SSLDIR/$SND
			exit 0
		fi
	else
		echo " "
		echo "##########################################################"
		echo "# $SND.md5 was not found                                 #"
		echo "# maybe it's not on the IHAD-server                      #"
		echo "# continuing backup without MD5-check                    #"
		echo "##########################################################"
		echo " "
	fi
	
########################################################################
echo "---------------------------------------------------------------"
echo "Checking free memory, about "$SWAPSIZE"MB will bee needed"
let MEMFREE=`free | grep Total | tr -s " " | cut -d " " -f 4 `/1024
  if [ "$MEMFREE" -lt $SWAPSIZE ]; then
  echo "Memory is smaller than "$SWAPSIZE"MB, FlashBackup has to create a swapfile"
echo "---------------------------------------------------------------"


  echo "Creating swapfile on $SWAPDIR with "$SWAPSIZE"MB"
  dd if=/dev/zero of=$SWAPDIR/swapfile_backup bs=1024k count=$SWAPSIZE
  mkswap $SWAPDIR/swapfile_backup
  swapon $SWAPDIR/swapfile_backup
echo "---------------------------------------------------------------"
  echo "Swapfile activated"
echo "---------------------------------------------------------------"

else
  echo "memory="$MEMFREE"MB=OK"
fi
echo "***********************************************"

starttime="$(date +%s)"
echo "* FlashBackup started at: `date +%H:%M:%S`          *"
echo "***********************************************"

rm -rf $DIRECTORY/bi
mkdir -p $DIRECTORY/bi
mkdir -p /tmp/bi/root
mkdir -p /tmp/bi/boot

mount -t jffs2 /dev/mtdblock/$MTDROOT /tmp/bi/root
mount -t jffs2 /dev/mtdblock/$MTDBOOT /tmp/bi/boot

if [ -s /tmp/secondstage.bin ] ; then
	echo "create boot.jffs2..."
	$MKFS --root=/tmp/bi/boot --faketime --output=$DIRECTORY/bi/boot.jffs2 $OPTIONS
	echo "create root.jffs2..."
	$MKFS --root=/tmp/bi/root --faketime --output=$DIRECTORY/bi/root.jffs2 $OPTIONS
	echo "create Secondstageloader..."
	if [ $BOXTYPE = "dm800" -o $BOXTYPE = "dm8000" -o $BOXTYPE = "dm500hd" -o $BOXTYPE = "dm800se" ] ; then
		cp /tmp/secondstage.bin $DIRECTORY/bi/main.bin.gz
	else
		gzip -c /tmp/secondstage.bin > $DIRECTORY/bi/main.bin.gz
	fi
	rm /tmp/secondstage.bin

	echo "create" $BOXTYPE "FlashBackup..."

	if [ $BOXTYPE = "dm7025" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm800" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE 64 > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm8000" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE 64 large > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm7020" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm600pvr" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm500plus" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm800se" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE 64 > $BACKUPIMAGE
	elif [ $BOXTYPE = "dm500hd" ] ; then
		$BUILDIMAGE $DIRECTORY/bi/main.bin.gz $DIRECTORY/bi/boot.jffs2 $DIRECTORY/bi/root.jffs2 $BOXTYPE 64 > $BACKUPIMAGE
	fi

 
	if [ -f $BACKUPIMAGE ] ; then
		echo "----------------------------------------------------------------------"
		echo "FlashBackup created in:" $BACKUPIMAGE
                echo "----------------------------------------------------------------------"
	fi
else
	echo "Download Error :("
  umount /tmp/bi/root
  umount /tmp/bi/boot
  rm -rf /tmp/bi
  rm -rf $DIRECTORY/bi
  exit 0
fi

if [ -s "$SWAPDIR"/swapfile_backup ] ; then

  swapoff $SWAPDIR/swapfile_backup
  rm -rf $SWAPDIR/swapfile_backup
  echo "deactivating an deleting swapfile"
echo "---------------------------------------------------------------"
fi
stoptime="$(date +%s)"
elapsed_seconds="$(expr $stoptime - $starttime)"
echo "***********************************************"
echo "* FlashBackup finished at: `date +%H:%M:%S`            *"
echo "* Duration of FlashBackup: $((elapsed_seconds / 60))minutes $((elapsed_seconds % 60))seconds *"
echo "***********************************************"

fi
umount /tmp/bi/root
umount /tmp/bi/boot
rm -rf /tmp/bi
rm -rf $DIRECTORY/bi
  echo "--------------------------------------------------"
  echo "------------------- DOMICA -----------------------"
  echo "--------------------------------------------------"
fi
exit
