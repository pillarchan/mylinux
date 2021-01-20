#!/bin/bash
#斐波那契数列
fib(){
  if [ $1 -le 2 ];then
    echo "1"
  else
    echo -n "$[$(fib $[$1-1])+$(fib $[$1-2])]"
  fi
}

fib $1
