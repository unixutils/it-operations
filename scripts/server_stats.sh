#!/bin/bash
# simple bash script to fetch server stats from remote system
# created by: vijayendar gururaja
    clear
    echo "Enter Hostname(s) with space in between"
    echo "Type 'X' to exit"
    read -a Hostname
      if [ "${Hostname[0]}" == x ] || [ "${Hostname[0]}" == X ]; then
       :
      else
        for i in "${Hostname[@]}"
          do
             ssh -T -o ConnectTimeout=10 -o ConnectionAttempts=1 37148@$i <<'EOF'
             # if you need to ssh as different user replace 'username' with the actual username 
             # ssh -T -o ConnectTimeout=10 -o ConnectionAttempts=1 username@$i <<'EOF'
                     echo "Generated on", $(date)
                     echo "-----Hostname & OS-----"
                     hostname
                     uname
                     cat /etc/*release 2> /dev/null
                     echo ""
                     echo "-----Uptime & Load Avg-----"
                     uptime
                     echo ""
                     echo "-----CPU Usage-----"
                     top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{n=split($1, vs, ","); v=vs[n]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }'
                     echo ""
                     echo "-----Memory Usage-----"
                     echo `free | awk 'FNR == 3 {print $3/($3+$4)*100}'`%
                     echo ""
                     echo "-----Mount points with 90%+ disk usage-----"
                     echo "Filesystem            Size  Used Avail Use% Mounted on"
                     df -Ph | awk '0+$5 >= 90 {print}'
                     echo ""
                     echo "-----Top Processess-----"
                     echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
                     ps auxf | sort -nr -k 4 | head -10
                     echo ""
EOF
           done >> server_stats_op.`date +%Y-%m-%d%H%M%S`.txt
      fi
