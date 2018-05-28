#!/bin/bash
# Bash Script to identify disk, Vendor name, Serial & WWN for all kinds of Mounted Block devices
# created by vijayendar gururaja
for i in `lsblk | grep disk | egrep -v 'Vx|ram|raw|loop|fd|md|dm-|sr|scd|st' | awk '{ print $1 }'`
do
   lsblk /dev/$i | awk '{print "MOUNT="$NF}' | grep -i '/'
   if [ $? = "0" ]; then
     lsblk /dev/$i | grep disk | awk '{print "BLOCK_SIZE="$4}'
     udevadm info --query=all --name /dev/$i | egrep 'DEVNAME=|ID_VENDOR=|ID_SERIAL_RAW=|ID_WWN=|ID_PATH=|ID_SCSI_SERIAL=' | awk '{ print $2 }'
     echo "--------------"
   fi
done
