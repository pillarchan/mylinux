#!/bin/bash
#打印NN乘法表；

num=$1
multi(){
for ((i=1;i<=$num;i++));do
  for ((j=1;j<=$i;j++));do
    echo -e -n "${i}X${j}=$[$i*$j]\t"
  done
  echo
done
}
multi $num
