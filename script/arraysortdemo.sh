#!/bin/bash
#练习：生成10个随机数，而后由小到大进行排序；
declare -a arr
for ((i=0;i<10;i++));do
  arr[i]=$RANDOM
done
echo "${arr[*]}"
for ((j=0;j<${#arr[*]};j++));do
  for ((k=0;k<$[${#arr[*]}-1];k++));do
    if [ ${arr[k]} -gt ${arr[k+1]} ];then
      tmp=${arr[k+1]}
      arr[k+1]=${arr[k]}
      arr[k]=$tmp
    fi
  done
done
echo "${arr[*]}"
