#!/bin/bash

echo "SODf"
disk_space=`df -Pl|grep '^/dev'|awk '{print $5}'|sed 's/%//'`
echo ${disk_space}
echo "EODf"

echo "SOHostname"
hostname
echo "EOHostname"

echo "SODate"
date
echo "EODate"

echo "SOUptime"
uptime
echo "EOUptime"

echo "SOState"
cpucount=`cat /proc/cpuinfo | grep -i processor | wc -l`
load=`cat /proc/loadavg | awk '{print $1}'`
response=`echo | awk -v T=$cpucount -v L=$load 'BEGIN{if ( L > T){ print "greater"}}'`
if [[ $response = "greater" ]]
then
echo "Overloaded"
else
echo "OK"
fi
echo "EOState"

echo "SOCpu"
top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{n=split($1, vs, ","); v=vs[n]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }'
echo "EOCpu"

echo "SOMemory"
echo `free | awk 'FNR == 3 {print $3/($3+$4)*100}'`%
echo "EOMemory"

echo "<!--SOMountpoint-->"
echo "<pre>"
df -Th
echo "</pre>"
echo "<!--EOMountpoint-->"

echo "<!--SOProcess-->"
echo "<pre>"
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
ps auxf | sort -nr -k 4 | head -10
echo "</pre>"
echo "<!--EOProcess-->"

echo "<!--SOHosttype-->"
count_vm=`cat /proc/scsi/scsi | grep -i vm |wc -l`
if [ $count_vm -ne 0 ];
then
echo "vm"
else
echo "physical"
fi
echo "<!--EOHosttype-->"
