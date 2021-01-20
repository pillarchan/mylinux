#!/bin/bash
#使用递归算阶乘
#n!=n*(n-1)
factorial(){
  if [ $1 -eq 0 -o $1 -eq 1 ];then
    echo "1"
  else
    echo $[$1*$(factorial $[$1-1])]
  fi
}

factorial $1
