#!/bin/bash
#能探测C类、B类或A类网络中的所有主机是否在线；

cping(){
  local i=1
  while [ $i -le 5 ];do 
    ping -W 1 -c 2 $1.$i &> /dev/null
    if [ $? -eq 0 ];then
      echo "$1.$i is up"      
    else
      echo "$1.$i is down"
    fi
    let i++
  done  
}
bping(){
  local j=0
  while [ $j -le 5 ];do
    cping $1.$j
    let j++
  done
}
aping(){
  local k=0
  while [ $k -le 5 ];do
    bping $1.$k
    let k++
  done  
}
aping 10
