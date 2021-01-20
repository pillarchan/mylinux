#!/bin/bash
#示例：给定一个用户名，取得用户的id号和默认shell；
userinfo() {
  if [ $userlen -lt 1 ];then
    echo "username is required"
    exit 2
  fi  
  if id $username &> /dev/null ;then
    grep "^$username\>" /etc/passwd | cut -d: -f3,7
  else
    echo "$username is not exist"
  fi  
}
userlen=$#
username=$1
userinfo

