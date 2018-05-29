#!/bin/bash
export PATH="$PATH:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
webpath=/opt/mylinuxmon/web
corepath=/opt/mylinuxmon/core
source $corepath/mylinuxmon.config

if [ -f $corepath/mylinuxmon.pid ]; then
#break
exit 1
else
#create PID file
touch $corepath/mylinuxmon.pid && echo $! > $corepath/mylinuxmon.pid
fi

check_hosts=`cat $corepath/host_list | head -n 1 | tr -d "[:blank:]" | wc -c`
if [ $check_hosts -lt 2 ]; then
cat $webpath/alert_host_empty.html > $webpath/index.html
rm -f $corepath/mylinuxmon.pid
exit 1
fi

cpu_threshold_trim=`echo $cpu_threshold | awk -F. '{print $1}' | sed 's/%//' | cut -c 1-3`
mem_threshold_trim=`echo $mem_threshold | awk -F. '{print $1}' | sed 's/%//' | cut -c 1-3`
disk_threshold_trim=`echo $disk_threshold | awk -F. '{print $1}' | sed 's/%//' | cut -c 1-3`

if [[ -z "$cpu_threshold_trim" ]]
then
cpu_threshold_trim=85
fi

if [[ -z "$mem_threshold_trim" ]]
then
mem_threshold_trim=85
fi

if [[ -z "$disk_threshold_trim" ]]
then
disk_threshold_trim=85
fi

disk_breach=no

echo "" > $webpath/index_pre.html
rm -rf $corepath/output/*
rm -rf $webpath/logs/*
cat $corepath/head.txt >> $webpath/index_pre.html
echo '<br />' >> $webpath/index_pre.html
#echo "Last Updated: $(date)" >> $webpath/index_pre.html
echo '<thead>' >> $webpath/index_pre.html
echo '<tr class="header">' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(0)">HostName&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(1)">Type&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(2)">Server Time&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(3)">Uptime and Load&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(4)">Load Status&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(5)">CPU usage&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(6)">Memory Usage&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(7)">Mountpoints critical&#160;&#160;</th>' >> $webpath/index_pre.html
echo '<th style="background-color:#f8be1b; color:#ffffff" onclick="sortTable(8)">Top processess&#160;&#160;</th>' >> $webpath/index_pre.html
echo '</tr>' >> $webpath/index_pre.html
echo '</thead>' >> $webpath/index_pre.html
echo '<tbody>' >> $webpath/index_pre.html

pssh -h $corepath/host_list -t 40 -o $corepath/output/ -I < $corepath/commands.sh
FILES=$corepath/output/*
for f in $FILES
do
#var_hostname=`sed -n -e '/SOHostname/,/EOHostname/ p' $f | sed -n '2p'`
var_hostname=$(basename $f)
var_date=`sed -n -e '/SODate/,/EODate/ p' $f | sed -n '2p'`
var_uptime=`sed -n -e '/SOUptime/,/EOUptime/ p' $f | sed -n '2p'`
var_state=`sed -n -e '/SOState/,/EOState/ p' $f | sed -n '2p'`
var_cpu=`sed -n -e '/SOCpu/,/EOCpu/ p' $f | sed -n '2p'`
var_memory=`sed -n -e '/SOMemory/,/EOMemory/ p' $f | sed -n '2p'`
var_hosttype=`sed -n -e '/SOHosttype/,/EOHosttype/ p' $f | sed -n '2p'`
var_df=`sed -n -e '/SODf/,/EODf/ p' $f | sed -n '2p'`

echo "<tr>"

if [ -z "$var_hostname" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
else
echo '<td style="background-color:#444444; color:#ffffff">'
echo "$var_hostname"
echo '</td>'
fi



if [ -z "$var_hosttype" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
else
echo '<td>'
echo $var_hosttype
echo '</td>'
fi



if [ -z "$var_date" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
else
echo '<td>'
echo $var_date
echo '</td>'
fi


if [ -z "$var_uptime" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
else
echo '<td>'
echo $var_uptime
echo '</td>'
fi



if [ -z "$var_state" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
elif [[ $var_state = "Overloaded" ]]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">'$var_state'</span>'
echo '</td>'
else
echo '<td>'
echo $var_state
echo '</td>'
fi


var_cpu_alert=`echo $var_cpu | awk -F. '{print $1}' | sed 's/%//' | cut -c 1-3`
if [ -z "$var_cpu" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
elif [ $var_cpu_alert -ge $cpu_threshold_trim ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">'$var_cpu'</span>'
echo '</td>'
else
echo '<td>'
echo $var_cpu
echo '</td>'
fi



var_memory_alert=`echo $var_memory | awk -F. '{print $1}' | sed 's/%//' | cut -c 1-3`
if [ -z "$var_memory" ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo '</td>'
elif [ $var_memory_alert -ge $mem_threshold_trim ]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">'$var_memory'</span>'
echo '</td>'
else
echo '<td>'
echo $var_memory
echo '</td>'
fi


sed -n -e '/<!--SOMountpoint-->/,/<!--EOMountpoint-->/ p' $f > $webpath/logs/mountlog.$var_hostname.html
sed -n -e '/<!--SOProcess-->/,/<!--EOProcess-->/ p' $f > $webpath/logs/proclog.$var_hostname.html

disk_breach=no
disk_arr=(`echo ${var_df}`);
for number in `echo ${disk_arr[*]}`; do
if [ $number -ge $disk_threshold_trim ]; then
disk_breach=yes
fi
done

if [ "$disk_breach" == "yes" ]
then
echo '<td style="background-color:#e9d393">'
echo '<a href="/logs/mountlog.'$var_hostname'.html"><span style="color:red; font-weight:bold">view</span></a>'
echo "</td>"
elif [[ -z "$var_date" ]]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo "</td>"
else
echo '<td>'
echo '<a href="/logs/mountlog.'$var_hostname'.html">view</a>'
echo "</td>"
fi

if [[ -z "$var_date" ]]
then
echo '<td style="background-color:#e9d393">'
echo '<span style="color:red; font-weight:bold">Failed</span>'
echo "</td>"
else
echo '<td>'
echo '<a href="/logs/proclog.'$var_hostname'.html">view</a>'
echo "</td>"
fi

echo "</tr>"
done >> $webpath/index_pre.html
echo "</tbody>" >> $webpath/index_pre.html
cat $corepath/tail.txt >> $webpath/index_pre.html
mv $webpath/index_pre.html $webpath/index.html
rm -f $corepath/mylinuxmon.pid


