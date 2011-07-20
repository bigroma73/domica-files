#!/bin/sh
#
# cronmanager.sh by gutemine
#
VERSION=22
#
INSTALLDIR=/tmp
#
# device specific variables
#
if [ -e /bin/enigma ]; then
   #echo "Running on enigma"
   #UNIVERSAL="-u"
   UNIVERSAL=""
   CMHOME=/var/etc/cron
   CMHOMETABS=/var/etc/crontab
else
   #echo "Running on enigma2"
   CMHOME=/etc/cron
   CMHOMETABS=/etc/cron/crontabs
   CMTMP=/tmp/.cmtmp
fi
# device paths
#
CRONDAEMONSCRIPT=/etc/init.d/busybox-cron 
HELP=$CMHOME/readme.txt
PLUGINDIR=/usr/lib/enigma2/python/Plugins/Extensions
MAKEKIT=$CMHOME/makekit.sh
CMSTART=S21cron
CMSTOP=K21cron
CRONTAB=/usr/bin/crontab
CRONTABFILE=$CMHOME/crontabfile
#
THINK=5
BZIP2=/usr/bin/bzip2
DEBUG=$CMHOME/.cmdebug
CMCONFIG=".cmconfig"
CMTYPE=""


if [ -f $DEBUG ]; then
             echo "----------------------------------------------------"
#             echo $0 $1 $2 $3 $4 $5 $6
             wall "$0 $1 $2 $3 $4 $5 $6"
             echo "----------------------------------------------------"
#             exit 0
fi

if  [ ! -d $INSTALLDIR ]; then
        mkdir $INSTALLDIR
fi

if  [ -f $CMHOME/$CMCONFIG ]; then
    CMTYPE=`cat $CMHOME/$CMCONFIG`
fi
# echo "Instalation type $CMTYPE"
# exit 0


cd /

case "$1" in
   "readme")
      echo "-----------------------------------------------------"
      cat $HELP
      echo "-----------------------------------------------------"
      exit 0
   ;;
   "reboot")
      echo "------------------------------------------"
      echo "Rebooting in $THINK seconds"  
      echo "------------------------------------------"
      sleep $THINK
      echo "Rebooting NOW"
      echo "------------------------------------------"
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma2 > /dev/null 2>&1
      if [ -f /sbin/reboot ]; then 
      reboot
      else   
      shutdown -r now
      fi
      exit 0
   ;;
   "halt")
      echo "------------------------------------------"
      echo "Shutdown in $THINK seconds"  
      echo "------------------------------------------"
      sleep $THINK
      echo "Shutting down NOW"
      echo "------------------------------------------"
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma2 > /dev/null 2>&1
      if [ -f /sbin/halt ]; then 
      halt
      else
      shutdown -h now
      fi
      exit 0
   ;;
   "kill")
      echo "------------------------------------------"
      if [ -f /bin/enigma ]; then
         echo "enigma will be restarted NOW"
         killall enigma
         echo "------------------------------------------"
         exit 0
      fi
      if [ -f /bin/neutrino ]; then
         echo "Neutrino kill not implemented, use restart instead"
         echo "------------------------------------------"
         exit 0
      fi
      echo "------------------------------------------"
      echo "enigma2 will be restarted NOW"
      echo "------------------------------------------"
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma2 > /dev/null 2>&1
      init 3
      exit 0
   ;;
   "time")
      echo "------------------------------------------"
      echo "showing current system time and date cron daemon is using"
      echo "------------------------------------------"
      date
      echo "------------------------------------------"
   ;;
   "start")
echo "-----------------------------------------------------"
   echo "Starting cron daemon ..."
   if [ -f /bin/enigma ]; then
      /var/bin/crond > /dev/null 2<&1 &
   else
      $CRONDAEMONSCRIPT start
   fi
echo "-----------------------------------------------------"
   exit 0
   ;;
   "stop")
echo "-----------------------------------------------------"
   echo "Stopping cron daemon ..."
   if [ -f /bin/enigma ]; then
      killall crond
   else
      $CRONDAEMONSCRIPT stop
   fi
echo "-----------------------------------------------------"
   exit 0
   ;;
   "restart")
echo "-----------------------------------------------------"
   echo "Restarting cron dameon ..."
   if [ -f /bin/enigma ]; then
      killall crond
      /var/bin/crond > /dev/null 2<&1 &
   else
      $CRONDAEMONSCRIPT restart
   fi
echo "-----------------------------------------------------"
   exit 0
   ;;
   "reload")
echo "-----------------------------------------------------"
   echo "Reloading crontab ..."
   $CRONDAEMONSCRIPT reload
echo "-----------------------------------------------------"
   exit 0
   ;;
   "list")
echo "-----------------------------------------------------"
   echo "Listing crontab ..."
echo "-----------------------------------------------------"
   if [ -f /bin/enigma ]; then
   if [ -f /var/etc/crontab ]; then
      cat /var/etc/crontab
   fi
   else
      $CRONTAB -l
   fi
echo "-----------------------------------------------------"
   exit 0
   ;;
   "delete")
echo "-----------------------------------------------------"
   echo "Deleting crontab ..."
   if [ -f /bin/enigma ]; then
      rm /var/etc/crontab
   else 
      $CRONTAB -d
   fi
echo "-----------------------------------------------------"
   exit 0
   ;;
   "info")
echo "-----------------------------------------------------"
echo "Check next line if cron dameon is running"
echo "-----------------------------------------------------"
   if [ -f /bin/enigma ]; then
ps ax | grep /var/bin/crond 
else
ps  | grep /usr/sbin/crond | grep crontab
fi
echo "-----------------------------------------------------"
;;
   "enable")
   echo
   if [ -f /bin/enigma ]; then
      echo "crond ist automatically enabled for enigma1 - maybe reboot"
      cp /var/etc/cron/init /var/etc/init
      rm -r /usr/lib/enigma2/python/Plugins/Extensions/Cronmanager > /dev/null 2>&1
      exit 0
   fi
   if [ -f /bin/neutrino ]; then
      echo "Enabling crond Startung on Neutrino - reboot to start dameon"
      grep -v "/etc/init.d/busybox-cron start" /etc/init.d/rcS > /tmp/.disable
      cp /tmp/.disable /etc/init.d/rcS 
      echo "/etc/init.d/busybox-cron start" >> /etc/init.d/rcS
      exit 0
   fi
   echo "-----------------------------------------------------"
   echo "Enabling / Updating Cronmanager ..."
   mkdir $CMHOME > /dev/null 2>&1
   cd $CMHOME
   mkdir $CMHOME/crontabs > /dev/null 2>&1
   if [ -d $CMHOME/var ]; then
      rm -r $CMHOME/var > /dev/null 2>&1
   fi
   if [ -d $CMHOME/usr ]; then
      rm -r $CMHOME/usr > /dev/null 2>&1
   fi
   ln -sfn $CRONDAEMONSCRIPT /etc/rc3.d/$CMSTART
   # default is CET = GMT+1
   TIMEZONE=1
   ln -sfn /usr/share/zoneinfo/CET /etc/localtime
   if [ `grep config.timezone /etc/enigma2/settings | wc -l` -gt 0 ]; then
      grep config.timezone /etc/enigma2/settings > $CMTMP
      if [ `grep GMT $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=0
          rm /etc/localtime > /dev/null 2>&1
      fi
      if [ `grep "GMT+02:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=2
          ln -sfn /usr/share/zoneinfo/Istanbul /etc/localtime
      fi
      if [ `grep "GMT+03:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=3
          ln -sfn /usr/share/zoneinfo/Baghdad /etc/localtime
      fi
      if [ `grep "GMT+03:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=3.5
          ln -sfn /usr/share/zoneinfo/Tehran /etc/localtime
      fi
      if [ `grep "GMT+04:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=4
          ln -sfn /usr/share/zoneinfo/Muscat /etc/localtime
      fi
      if [ `grep "GMT+04:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=4.5
          ln -sfn /usr/share/zoneinfo/Kabul /etc/localtime
      fi
      if [ `grep "GMT+05:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=5
          ln -sfn /usr/share/zoneinfo/Tashkent /etc/localtime
      fi
      if [ `grep "GMT+05:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=5.5
          ln -sfn /usr/share/zoneinfo/Calcutta /etc/localtime
      fi
      if [ `grep "GMT+05:45" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=5.75
          ln -sfn /usr/share/zoneinfo/Katmandu /etc/localtime
      fi
      if [ `grep "GMT+06:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=6
          ln -sfn /usr/share/zoneinfo/Almaty /etc/localtime
      fi
      if [ `grep "GMT+06:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=6.5
          ln -sfn /usr/share/zoneinfo/Rangoon /etc/localtime
      fi
      if [ `grep "GMT+07:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=7
          ln -sfn /usr/share/zoneinfo/Bangkok /etc/localtime
      fi
      if [ `grep "GMT+08:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=8
          ln -sfn /usr/share/zoneinfo/Hong_Kong /etc/localtime
      fi
      if [ `grep "GMT+09:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=9
          ln -sfn /usr/share/zoneinfo/Tokyo /etc/localtime
      fi
      if [ `grep "GMT+09:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=9.5
          ln -sfn /usr/share/zoneinfo/Adelaide /etc/localtime
      fi
      if [ `grep "GMT+10:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=10
          ln -sfn /usr/share/zoneinfo/Brisbane /etc/localtime
      fi
      if [ `grep "GMT+11:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=11
          ln -sfn /usr/share/zoneinfo/Magadan /etc/localtime
      fi
      if [ `grep "GMT+12:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=12
          ln -sfn /usr/share/zoneinfo/Auckland /etc/localtime
      fi
      if [ `grep "GMT+13:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=13
          ln -sfn /usr/share/zoneinfo/Tongatapu /etc/localtime
      fi
      if [ `grep "GMT-12:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-12
#         ln -sfn /usr/share/zoneinfo/UNKNOWN /etc/localtime
          rm /etc/localtime > /dev/null 2>&1
      fi
      if [ `grep "GMT-11:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-11
          ln -sfn /usr/share/zoneinfo/Midway /etc/localtime
      fi
      if [ `grep "GMT-10:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-10
          ln -sfn /usr/share/zoneinfo/Honolulu /etc/localtime
      fi
      if [ `grep "GMT-09:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-9
          ln -sfn /usr/share/zoneinfo/Anchorage /etc/localtime
      fi
      if [ `grep "GMT-08:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-8
          ln -sfn /usr/share/zoneinfo/Tijuana /etc/localtime
      fi
      if [ `grep "GMT-07:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-7
          ln -sfn /usr/share/zoneinfo/MST7MDT /etc/localtime
      fi
      if [ `grep "GMT-06:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-6
          ln -sfn /usr/share/zoneinfo/Saskatchewan /etc/localtime
      fi
      if [ `grep "GMT-05:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-5
          ln -sfn /usr/share/zoneinfo/Bogota /etc/localtime
      fi
      if [ `grep "GMT-04:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-4
          ln -sfn /usr/share/zoneinfo/Caracas /etc/localtime
      fi
      if [ `grep "GMT-03:30" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-3.5
          ln -sfn /usr/share/zoneinfo/Newfoundland /etc/localtime
      fi
      if [ `grep "GMT-03:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-3
#         ln -sfn /usr/share/zoneinfo/UNKNOWN /etc/localtime
          rm /etc/localtime > /dev/null 2>&1
      fi
      if [ `grep "GMT-02:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-2
          ln -sfn /usr/share/zoneinfo/Noronha /etc/localtime
      fi
      if [ `grep "GMT-01:00" $CMTMP | wc -l` -gt 0 ]; then
          TIMEZONE=-1
          ln -sfn /usr/share/zoneinfo/Azores /etc/localtime
      fi
   fi
   echo "-----------------------------------------------------"
   echo "Timezone: GMT $TIMEZONE"
   echo "-----------------------------------------------------"
   echo "linked zoneinfo:"
   echo "-----------------------------------------------------"
   ls -alh /etc/localtime
   echo "-----------------------------------------------------"

   if [ -f /bin/enigma ]; then
      echo "Running on enigma"
      echo "Dreambox reboots in 5 secs, after this cron daemon should"
      echo "be running - check with cronmanager info"
      echo "-----------------------------------------------------"
      sleep 5
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma > /dev/null 2>&1
      shutdown -r now
      exit 0
   fi
   if [ -f /bin/neutrino ]; then
      echo "Running on neutrino"
      echo "Dreambox reboots in 5 secs, after this cron daemon should"
      echo "be running - check with cronmanager info"
      echo "-----------------------------------------------------"
      sleep 5
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 neutrino > /dev/null 2>&1
      reboot
      exit 0
   fi
   #echo "Running on enigma2"
   $CRONDAEMONSCRIPT restart
   echo "-----------------------------------------------------"
   echo "Enabling Cronmanager and cron daemon finished !"
   echo "-----------------------------------------------------"
   exit 0
;; 
   "disable")
   echo "-----------------------------------------------------"
   echo "Disabling Cronmanager ..."
   echo "-----------------------------------------------------"
   if [ -f /bin/enigma ]; then
      echo "disabling crond on enigma1, maybe reboot"
      killall  crond
      rm /var/etc/init
      echo "-----------------------------------------------------"
      echo "Dreambox reboots in 5 secs, after this cron dameon should"
      echo "be disabled and cronmanager deinstalled"
      echo "-----------------------------------------------------"
      sleep 5
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma > /dev/null 2>&1
      shutdown -r now
      exit 0
   fi
   if [ -f /bin/neutrino ]; then
      grep -v "/etc/init.d/busybox-cron start" /etc/init.d/rcS > /tmp/.disable
      cp /tmp/.disable /etc/init.d/rcS 
      echo "-----------------------------------------------------"
      echo "Dreambox reboots in 5 secs, after this cron dameon should"
      echo "be disabled and cronmanager deinstalled"
      echo "-----------------------------------------------------"
      sleep 5
      init 4 > /dev/null 2>&1
      sleep 5
      killall -9 enigma > /dev/null 2>&1
      shutdown -r now
      exit 0
   fi
   cd /
   $CRONDAEMONSCRIPT stop
   if [ -f /etc/rc3.d/$CMSTART ] ; then
      rm /etc/rc3.d/$CMSTART
   fi
   if [ -d $PLUGINDIR/Cronmanager ]; then
      rm -r $PLUGINDIR/Cronmanager
   fi
   if [ -d $CMHOME ]; then
      rm -r $CMHOME
   fi

   echo "-----------------------------------------------------"
   echo "Deinstallation of cronmanager finished !"
   echo "-----------------------------------------------------"
   exit 0
;;
"delay")
if  [  ! $2 ]; then
     echo "No command passed, cann't do anything - exiting !"
     echo "-----------------------------------------------------"
     exit 1
else
    CRONCOMMAND=$2
    if [  ! -f $CRONCOMMAND ]; then
       echo "Command $CRONCOMMAND doesn't exist - exiting !"
       echo "-----------------------------------------------------"
       exit 1
    fi
fi
if  [  ! $3 ]; then
    echo "No time passed, assuming 60 min"
    LATER=60
else
    LATER=$3
fi
if  [ $LATER -gt 1440 ]; then
    echo "time is longer then 1 day, use normal crontab entry for this, sorry"
    exit 1
fi
if  [ $LATER -lt 1 ]; then
    echo "time is too small, assuming 1 minute"
    LATER=1
fi
# processing time
CDATE=`date $UNIVERSAL`
CSEC=`date $UNIVERSAL +'%s'`
CHOUR=`date $UNIVERSAL +'%H'`
CMINUTE=`date $UNIVERSAL +'%M'`
CMONTH=`date $UNIVERSAL +'%m'`
CMONTHDAY=`date $UNIVERSAL +'%d'`
CWEEKDAY=`date $UNIVERSAL +'%w'`
#echo "Current time in seconds since 1970: $CSEC"
LSEC=`expr $LATER "*" 60`
#echo "Seconds in the Future $LSEC"
#LSEC=`expr $LSEC "+" $CSEC`
#echo "Later time in seconds since 1970: $LSEC"
#echo "Current time: $CDATE"
#echo "Current time in cron format: $CMINUTE $CHOUR $CMONTHDAY $CMONTH $CWEEKDAY"
DATE=`date -d $CHOUR:$CMINUTE:$LSEC`
HOUR=`date -d $CHOUR:$CMINUTE:$LSEC +'%H'`
MINUTE=`date -d $CHOUR:$CMINUTE:$LSEC +'%M'`
MONTH=`date -d $CHOUR:$CMINUTE:$LSEC +'%m'`
MONTHDAY=`date -d $CHOUR:$CMINUTE:$LSEC +'%d'`
WEEKDAY=`date -d $CHOUR:$CMINUTE:$LSEC +'%w'`
#echo "Later   time: $DATE"
#echo "Later   time in cron format: $MINUTE $HOUR $MONTHDAY $MONTH $WEEKDAY"
echo "--------------------------------------------------"
echo "new crontab line will be like this:"
echo "--------------------------------------------------"
FULLCOMMAND="$MINUTE $HOUR $MONTHDAY $MONTH $WEEKDAY $CRONCOMMAND"
echo $FULLCOMMAND > $CRONTABFILE
sed -ie s!"%"!!g $CRONTABFILE
cat $CRONTABFILE
if [ -f /bin/enigma ]; then
if [ -f /var/etc/crontab ]; then
cat /var/etc/crontab > $CRONTABFILE
else
rm $CRONTABFILE
touch $CRONTABFILE
fi
else
$CRONTAB -l > $CRONTABFILE 
fi
echo $FULLCOMMAND >> $CRONTABFILE
sed -ie s!"%"!!g $CRONTABFILE
#echo "--------------------------------------------------"
#echo "appendign line to crontab now ..."
if [ -f /bin/enigma ]; then
cp $CRONTABFILE /var/etc/crontab
else
$CRONTAB $CRONTABFILE
fi
echo "--------------------------------------------------"
echo "Displaying new crontab:"
echo "--------------------------------------------------"
if [ -f /bin/enigma ]; then
if [ -f /var/etc/crontab ]; then
cat /var/etc/crontab 
fi
else
$CRONTAB -l
fi
echo "--------------------------------------------------"
exit 0
;;
"add")
if [ ! $2 ]; then
   echo "No script passed, cann't do anything - exiting !"
   exit 1
else
  CRONCOMMAND=$2
  if [ ! -f $CRONCOMMAND ]; then
     echo "script $CRONCOMMAND doesn't exist - exiting !"
     exit 1
  fi
fi
#echo "script to be executed $CMHOME/$CRONCOMMAND"
if  [  ! $3 ]; then
    MINUTE="%*"
else
if  [  $3 -lt 0 ]; then
    MINUTE="%*"
else
if  [  $3 -gt 59 ]; then
    MINUTE="%*"
else
    MINUTE=$3
fi
fi
fi
#echo "Minute $MINUTE (0-59)"
if  [  ! $4 ]; then
    HOUR="%*"
else
if  [  $4 -lt 0 ]; then
    HOUR="%*"
else
if  [  $4 -gt 23 ]; then
    HOUR="%*"
else
    HOUR=$4
fi
fi
fi
#echo "Hour $HOUR (0-23)"
if  [  ! $5 ]; then
    MONTHDAY="%*"
else
if  [  $5 -lt 1 ]; then
    MONTHDAY="%*"
else
if  [  $5 -gt 31 ]; then
    MONTHDAY="%*"
else
    MONTHDAY=$5
fi
fi
fi
#echo "Day of month $MONTHDAY (1-31)"
if  [  ! $6 ]; then
    MONTH="%*"
else
if  [  $6 -lt 1 ]; then
    MONTH="%*"
else
if  [  $6 -gt 12 ]; then
    MONTH="%*"
else
    MONTH=$6
fi
fi
fi
#echo "Month $MONTH (1-12)"
if  [  ! $7 ]; then
    WEEKDAY="%*"
else
if  [  $7 -lt 0 ]; then
    WEEKDAY="%*"
else
if  [  $7 -gt 6 ]; then
    WEEKDAY="%*"
else
    WEEKDAY=$7
fi
fi
fi
#echo "Day of week $WEEKDAY (0-6 Sunday = 6)"
echo "--------------------------------------------------"
echo "new crontab line will be like this:"
echo "--------------------------------------------------"
FULLCOMMAND="$MINUTE $HOUR $MONTHDAY $MONTH $WEEKDAY $CRONCOMMAND"
echo $FULLCOMMAND > $CRONTABFILE
sed -ie s!"%"!!g $CRONTABFILE
cat $CRONTABFILE
if [ -f /bin/enigma ]; then
if [ -f /var/etc/crontab ]; then
cat /var/etc/crontab > $CRONTABFILE
else
rm $CRONTABFILE
touch $CRONTABFILE
fi
else
$CRONTAB -l > $CRONTABFILE 
fi
echo $FULLCOMMAND >> $CRONTABFILE
sed -ie s!"%"!!g $CRONTABFILE
#echo "--------------------------------------------------"
#echo "appendign line to crontab now ..."
if [ -f /bin/enigma ]; then
cp $CRONTABFILE /var/etc/crontab
else
$CRONTAB $CRONTABFILE
fi
echo "--------------------------------------------------"
echo "Displaying new crontab:"
echo "--------------------------------------------------"
if [ -f /bin/enigma ]; then
if [ -f /var/etc/crontab ]; then
cat /var/etc/crontab
fi
else
$CRONTAB -l
fi
echo "--------------------------------------------------"
exit 0
;;
  *)
    echo "-----------------------------------------------------"
    echo "Usage: $0 {list|add|delete|info|time|stop|start|restart|reload|"
    echo "                       enable|disable|reboot|halt|kill|readme}"
    echo "-----------------------------------------------------"
    echo "list       option lists the crontab"
    echo "add        option adds command to the crontab with time"
    echo "delay      option adds command to the crontab with delay"
    echo "delete     option deletes the crontab"
    echo "info       option displays info f cron dameon is running"
    echo "time       option displays current internal time used by cron dameon"
    echo "stop       option stops the cron dameon"
    echo "start      option starts the cron dameon"
    echo "restart    option restarts the cron dameon"
    echo "reload     option reloads the crontab"
    echo "enable     option enables cronmanager and cron daemon"
    echo "disable    option disables cronmanager and cron daemon"
    echo "reboot     option reboots Dreambox"
    echo "halt       option halts Dreambox - for example for flashing"
    echo "kill       option will restart only enigma2"
    echo "man        option displays longer help text"
    echo "-----------------------------------------------------"
    exit 1
;;
esac
exit 0
