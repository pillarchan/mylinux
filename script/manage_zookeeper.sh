#!/bash/bin
function console_log(){
    echo "Usage: zkServer.sh {start|stop|version|restart|status}"
    exit 2
}
if [ "$#" -ne 1 ];then
    console_log
fi
case "$1" in
    "start")
        ansible zookeeper -m shell -a "zkServer.sh start"
        ;;
    "stop")
        ansible zookeeper -m shell -a "zkServer.sh stop"
        ;;
    "version")
        ansible zookeeper -m shell -a "zkServer.sh version"
        ;;
    "restart")
        ansible zookeeper -m shell -a "zkServer.sh restart"
        ;;
    "status")
        ansible zookeeper -m shell -a "zkServer.sh status"
        ;;
    *)
        console_log
        exit;
esac
