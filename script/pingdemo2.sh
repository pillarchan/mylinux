#!/bin/bash
#ping命令去查看172.16.1.1-172.16.67.1范围内的所有主机是否在线；在线的显示为up, 不在线的显示down，分别统计在线主机，及不在线主机数；
# 分别使用for, while和until循环实现。

uphost=0
downhost=0
message=""
num=1
pingtest(){
  ping -W 1 -c 2 $1 &> /dev/null;
  result=$?
    if [ $result -eq 0 ];then
      let uphost+=1
      message="is up"
    else
      let downhost+=1
      message="is down"
    fi
  echo "$1 $message"
}
forpingtest(){
  for ((i=1;i<=20;i++));do
    pingtest 192.168.0.$i
  done
  echo "uphost:$uphost,downhost:$downhost"
}
#forpingtest
whilepingtest(){
while [ $num -le 20 ];do
  pingtest 192.168.0.$num
  let num++
  done
  echo "uphost:$uphost,downhost:$downhost"
}
#whilepingtest
untilpingtest(){
  until [ $num -gt 20 ];do
    pingtest 192.168.0.$num
    let num++
  done
  echo "uphost:$uphost,downhost:$downhost"
}
untilpingtest
