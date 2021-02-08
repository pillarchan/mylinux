#!/bin/bash
MY_DIR_1="/home/wwwroot/chatservice/runtime"
if [ ! -e $MY_DIR_1 ]; then
    echo "${MY_DIR_1} is not exists"
    exit 0
fi

cd $MY_DIR_1
rm -rf ${MY_DIR_1}/*
chown -R www.www ${MY_DIR_1}
chmod -R 755  ${MY_DIR_1}
echo "`date +"%F %T"`" >> /opt/test1.log

MY_DIR_2="/home/wwwroot/chatApi/runtime"
if [ ! -e $MY_DIR_2 ]; then
    echo "${MY_DIR_2} is not exists"
    exit 0
fi

cd $MY_DIR_2
rm -rf  ${MY_DIR_2}/*
chown -R www.www ${MY_DIR_2}
chmod -R 755 ${MY_DIR_2}
echo "`date +"%F %T"`" >> /opt/test2.log
