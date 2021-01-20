#!/bin/bash
#练习：定义一个数组，数组中的元素是/var/log目录下所有以.log结尾的文件；统计其下标为偶数的文件中的行数之和；

declare -a logArr
logArr=(/var/log/*.log)
lines=0
for i in $(seq 0 $[${#logArr[*]}-1]);do
  if [ $[$i%2] -eq 0 ];then
    let lines+=$(wc -l ${logArr[$i]} | grep -o "^[0-9]\+")
  fi  
done

echo "$lines"
