#!/bin/bash
function start(){
    cd /data/yim-front-server;nohup java -jar -Xms512m -Xmx512m -Dspring.profiles.active=btu yim-front-server-1.0.0.jar &>/dev/null &
}
function restart(){
    /bin/kill -s TERM $(ps -A -opid,cmd | grep yim-front-server-1.0.0 | cut -d' ' -f2 | head -n1)
    cd /data/yim-front-server;nohup java -jar -Xms512m -Xmx512m -Dspring.profiles.active=btu yim-front-server-1.0.0.jar &>/dev/null &
}
function stop(){
    /bin/kill -s TERM $(ps -A -opid,cmd | grep yim-front-server-1.0.0 | cut -d' ' -f2 | head -n1)    
}

if [ $# -lt 1 ];then
    echo "useage bash yim_front_ms.sh <start|restart|stop>"
    exit 2
fi
case $1 in 
    "start")
    start
    ;;
    "restart")
    restart
    ;;
    "stop")
    stop
    ;;
    *)
    echo "useage bash yim_front_ms.sh <start|restart|stop>"
    exit 2   
esac
