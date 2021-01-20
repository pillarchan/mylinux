#!/bin/bash
htName='旺旺程序__'
curentDay=$(date +%F)
fileSuffix="daily_check.txt"
file_name="$curentDay$fileSuffix"
_dir="/home/admin/logs/"
full_path=$_dir$htName$file_name
if ! [ -d _dir ]; then
    mkdir -pv $_dir
fi
#lsof -n | egrep sshd.*ESTABLISHED > $_dir$htName$file_name
week=$( date | cut -d' ' -f1 )
month=$( date | cut -d' ' -f2 )
day=$( date | cut -d' ' -f3 )
sleep 2
touch $full_path
echo  "----------------------------------------" > $full_path
/usr/sbin/lsof -n | grep ESTABLISHED | grep -v 127.0.0.1 >> $full_path
last | grep "$week\s$month\s$day" >> $full_path
pstree >> $full_path
df -h >> $full_path
cp $full_path /tmp