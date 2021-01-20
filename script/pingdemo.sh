#!/bin/bash
#使用函数实现ping一个主机来测试主机的在线状态；主机地址通过参数传递给函数；
#主程序：测试172.16.1.1-172.16.67.1范围内各主机的在线状态；

pingtest(){
  ping $1 -c 4 &> /dev/null
  result=$?
  return $result
}
for i in $(seq 1 $1);do
  pingtest 192.168.0.$i
  resval=$?
  if [ $resval -eq 0 ];then
    echo "192.168.0.${i} is exist"
  else
    echo "192.168.0.${i} is inexistence"
  fi
done
