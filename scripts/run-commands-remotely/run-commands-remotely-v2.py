#!/bin/python
import os, sys
import paramiko
import subprocess
import smtplib
import socket
from email.mime.text import MIMEText

#declare default port
port=22

#declare path to files
path='/home/unixutils-admin/python_scripts/run-commands-remotely/'

#ssh connection
ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

#define function to send email
def send_email():
    email_msg_file="dump/"+host+".out"
    fp = open(email_msg_file, 'rb')
    msg = MIMEText(fp.read(), 'html')
    fp.close()
    me='noreply@unixutils.com'
    recipients=['admin@unixutils.com']
    msg['Subject'] = 'check-FS alert %s' % host
    msg['From'] = me
    msg['To'] = ", ".join(recipients)
    s = smtplib.SMTP('your-mail-relay-server.com')
    s.sendmail(me, recipients, msg.as_string())
    s.quit()

#open host file and read line by line
file_host_file=open(path+'/host_file',"r")
host_list=file_host_file.readlines()

#open commands file and read line by line
file_commands_file=open(path+'/commands_file',"r")
commands_list=file_commands_file.readlines()

#create directory 'dump' and dump o/p one file per host
dump_dir='dump'
for host in host_list:

    #remove whitespaces and convert each line from host file into an array 'j'
    #create hostname,username,password variables from array elements
    host = host.rstrip()
    j=host.split(' ')
    host=j[0]
    username=j[1]
    password=j[2]
    os_check="uname -a | awk '{print $1}'"

    #run
    for cmd in commands_list:
        try:
            ssh.connect(host,port,username,password)
            stdin,stdout,stderr=ssh.exec_command(os_check,get_pty=True)
            check=stdout.readlines()
            check_op="".join(check)
            check_op = check_op.rstrip()
            ssh.close()
            if check_op == 'Linux' :
                cmd = cmd.rstrip()
                ssh.connect(host,port,username,password)
                stdin,stdout,stderr=ssh.exec_command(cmd,get_pty=True)
                outlines=stdout.readlines()
                resp="".join(outlines)
                if not os.path.exists(dump_dir):
                    os.makedirs(dump_dir)
                op = open("dump/%s.out" % host, "w")
                op.write(resp)
                op.close()
                ssh.close()
                if os.stat("dump/"+host+".out").st_size != 0 :
                    send_email()
            else:
                if not os.path.exists(dump_dir):
                    os.makedirs(dump_dir)
                op = open("dump/%s.out" % host, "w")
                op.write("OS Not supported")
                op.close()
                ssh.close()
                if os.stat("dump/"+host+".out").st_size != 0 :
                    send_email()
        except paramiko.SSHException, e:
            if not os.path.exists(dump_dir):
                os.makedirs(dump_dir)
            op = open("dump/%s.out" % host, "w")
            op.write("Password is invalid")
            op.close()
            ssh.close()
            if os.stat("dump/"+host+".out").st_size != 0 :
                    send_email()
        except paramiko.AuthenticationException:
            if not os.path.exists(dump_dir):
                os.makedirs(dump_dir)
            op = open("dump/%s.out" % host, "w")
            op.write("Password is invalid")
            op.close()
            ssh.close()
            if os.stat("dump/"+host+".out").st_size != 0 :
                    send_email()
        except socket.error, e:
            if not os.path.exists(dump_dir):
                os.makedirs(dump_dir)
            op = open("dump/%s.out" % host, "w")
            op.write("Connection to server failed")
            op.close()
            ssh.close()
            if os.stat("dump/"+host+".out").st_size != 0 :
                    send_email()
file_host_file.close()
