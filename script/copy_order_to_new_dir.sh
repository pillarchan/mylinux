#!/bin/bash
#(1) 提示用户输入一个可执行命令的名称；
read -p "please input a order": ordername

orderpath=""
prefix=""
checkordername(){
  [ $# -lt 1 ] && echo "one ordername is reqiured" &&  exit 2
    which $1 &> /dev/null
    local result=$?
    return $result  
}
#(2) 获取此命令所依赖到的所有库文件列表；
getdependencies(){
  checkordername $1
     local resval=$?
      if [ $resval -eq 0 ];then
         prefix=/mnt/sysroot
         orderpath=$(which $1)
         deplist=$(ldd $orderpath | grep -o "/[^[:space:]]\+\>" )
      else
        echo "$1 is not exist"
        exit $resval
      fi
}
#(3) 复制命令至某目标目录（例如/mnt/sysroot，即把此目录当作根）下的对应的路径中
copyordertodir(){
 checkordername $1
 local resval=$?
 if [ $resval -eq 0 ];then
#   prefix=/mnt/sysroot
   if ! [ -d "$prefix" ];then
      mkdir "$prefix"
   fi
   local suffix=${orderpath%/*}
   echo $suffix
   if ! [ -d "$prefix$suffix" ];then
    mkdir -p "$prefix$suffix"
   fi
   if [ -e "$prefix$orderpath" ];then
    rm -f "$prefix$orderpath" 
   fi
   cp -r "$orderpath" "$prefix$suffix"
   echo "copy orderpath done"
 else
   echo "$1 is not exist"
   exit $resval  
 fi
}
#(4) 复制此命令依赖到的所有库文件至目标目录下的对应路径下；
copydependencies(){
 getdependencies $1
 for i in $deplist ;do
  local suffix=${i%/*}
  if ! [ -d "$prefix$suffix" ];then
   mkdir -p "$prefix$suffix"
  fi
  cp -r "$i" "$prefix$suffix" 
 done
 echo "copy done"
}
copydependencies $ordername
copyordertodir $ordername
