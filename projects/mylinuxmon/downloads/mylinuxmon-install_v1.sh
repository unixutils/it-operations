currentUser=`whoami`
if [ "$currentUser" != "root" ]
then
        echo "You're logged in as '$currentUser'. root privileges is neeeded to execute this file!"
        exit
fi

current_path=`pwd`
if [ ! -f $current_path/mylinuxmon_v1.tar.gz ]; then
    echo "$current_path/mylinuxmon_v1.tar.gz not found!"
    exit 1	
fi

echo "Enter userID to use for monitoring"
read var_mymonid
id $var_mymonid >> /dev/null 2>&1
return_var_mymonid=`echo $?`
if [ $return_var_mymonid -ne 0 ]; then
    echo "Invalid user ID"
    exit 1
fi
echo "Creating Application directories"

if [ ! -d /opt ]
then
        mkdir /opt
        chmod 775 /opt
        chown root /opt
fi

if [ -d /opt/mylinuxmon ]; then
while true
 do
  echo "Application directory 'mylinuxmon' already exists under /opt"
  echo "Would you like to overwrite? [y/n]?"
  read var_overwrite 
  case "$var_overwrite" in
   [yY][eE][sS]|[yY]) 
	rm -rf /opt/mylinuxmon/*
	break
	;;
			
   [nN][oO]|[nN]) 
	exit 1	
        break
	;;
   *)
	echo "invalid response. Please enter (y/N)"
	;;
  esac
 done
fi

python_version=$(python --version 2>&1)
return_python_version=$?

if [ $return_python_version -ne 0 ]; then
echo "Please Install python 2.x or above to install mylinuxmon"
echo "exiting"
exit 1
elif [ `echo $python_version | cut -d' ' -f2 | awk -F. '{print $1}'` -eq 2 ]; then
echo "Python 2.x found"
python_version_number=2
elif [ `echo $python_version | cut -d' ' -f2 | awk -F. '{print $1}'` -eq 3 ]; then
echo "Python 3.x found"
python_version_number=3
else
echo "2 Please install python version 2.x or 3.x to install mylinuxmon"
echo "exiting"
exit 1
fi


mkdir -p /opt/mylinuxmon/
echo "extracting files"
tar -zxf mylinuxmon_v1.tar.gz -C /opt/mylinuxmon/

checkpssh=`pssh --version`
return_checkpssh=$?

if [ $return_checkpssh -ne 0 ]; then
echo "Installing pssh"
cd /opt/mylinuxmon/pssh-2.3.1/
python ./ez_setup.py
python ./setup.py install
else
echo "PSSH found. Skipping"
fi
echo "Setting ownership and permissions"
chown -R $var_mymonid:root /opt/mylinuxmon/*
chmod +x /opt/mylinuxmon/core/commands.sh
chmod +x /opt/mylinuxmon/core/html_writer.sh

echo "Scheduling Monitoring"
if crontab -l | grep "/opt/mylinuxmon/core/html_writer.sh" >> /dev/null 2>&1 ; then 
:
else 
su -c 'echo "* * * * * /opt/mylinuxmon/core/html_writer.sh >> /dev/null 2>&1" | crontab' $var_mymonid
fi

ps -ef | grep 'python -m [S]impleHTTPServer 9000' | awk '{print $2}' | xargs kill -9 >> /dev/null 2>&1
cd /opt/mylinuxmon/web/
echo "Starting HTTP services as $var_mymonid.."
echo "Enter $var_mymonid System Password if Prompted.."
if [ $python_version_number -eq 2 ]; then
su -c "nohup python -m SimpleHTTPServer 9000" $var_mymonid >> /dev/null 2>&1 &
elif [ $python_version_number -eq 3 ]; then
su -c "nohup python3 -m http.server 9000" $var_mymonid >> /dev/null 2>&1 &
else
echo "Please Install python 2.x or above to install mylinuxmon"
echo "exiting"
fi
echo "****************************"
echo "Check status of hosts at http://Your-IP:9000 OR http://your-Hostname.domain:9000 on any Internet Browser"
echo "Enjoy! -www.UnixUtils.com"
echo "****************************"
