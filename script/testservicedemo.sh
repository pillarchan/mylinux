#!/bin/bash
#一个测试服务框架
#chkconfig - 50 50
#description:testservice

prog=$(basename $0)
lockfilename=/var/lock/subsys//testservice
start(){
  if [ -f $lockfilename ];then
    echo "$prog is started"
  else 
    touch $lockfilename
    [ $? -eq 0 ] && echo "$prog start done"
    fi
}

stop(){
  if [ -f $lockfilename ];then
    rm -f $lockfilename
    [ $? -eq 0 ] && echo "$prog stop done"
  else 
    echo "$prog is stoped"
    fi
}
status(){
  if [ -e $lockfilename ];then
    echo "$prog is running"
  else 
     echo "$prog is stoped"
    fi
}
usage(){
  echo "Usage:$prog {start|stop|restart|status}"
}
case $1 in
  start)
    start ;;
  stop)
    stop ;;
  restart)
    stop
    start ;;
  status)
    status  ;;
  *)
    usage
esac
