#!/bin/bash
if [ $# -eq 2 ];then
    if [[ -z "$#" ]];then
        echo "参数不能为空"
        exit 2
    elif [[ $(echo "$2" | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/[0-9]{1,2}$') != "$2" ]];then
        echo "ip格式为 1.1.1.1/1"
        exit 2
    else
        hostnamectl hostname $1
        sed -ri 's@[1-9]+.[1-9]+.[1-9]+.[1-9]+/24@$2@' /etc/netplan/00-installer-config.yaml
        netplan apply
    fi
else 
    echo "the 3 parameters are required"
    exit 2;
fi