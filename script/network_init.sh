#!/bin/bash
NETWORK_NAME=$(ip link | grep -E -o "(ens[0-9]+|eth[0-9]+)")
if [ $# -eq 2 ];then
    if [[ -z "$#" ]];then
        echo "参数不能为空"
        exit 2
    elif [[ $(echo "$2" | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/[0-9]{1,2}$') != "$2" ]];then
        echo "ip格式为 1.1.1.1/1"
        exit 2
    else
        hostnamectl set-hostname $1
        nmcli connection modify $NETWORK_NAME ipv4.addresses $2
        nmcli d reapply $NETWORK_NAME
    fi
else 
    echo "the 3 parameters are required"
    exit 2;
fi
