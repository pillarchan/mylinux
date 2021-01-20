#!/bin/bash
#添加用户的功能使用函数实现，用户名做为参数传递给函数；

#5 user exist 2 username is required
adduser(){
  if id $1 &> /dev/null;then
    return 5
  else
    useradd $1
    result=$?
    return $result
  fi
}
if [ $# -lt 1 ];then
  echo "username is required"
  exit 2
else   
  for i in {1..10};do
    adduser ${1}${i}
    resval=$?
    if [ $resval -eq 0 ];then
      echo "user ${1}${i} added successfully"
    elif [ $resval -eq 5 ];then
      echo "user ${1}${i} is exist"
      userdel -r ${1}${i}
    else
      echo "Unkonw error"
    fi  
  done
fi
