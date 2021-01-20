#!/bin/bash
#示例：生成10个随机数，并找出其中的最大值和最小值；

declare -a rand
max=0

for ((i=0;i<10;i++));do
  rand[$i]=$RANDOM
  if [ ${rand[$i]} -gt $max ];then
    max=${rand[$i]}
  fi
done  
echo "$max"
