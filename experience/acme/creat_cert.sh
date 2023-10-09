#!/bin/bash
if [ $# -eq 1 ];then
    if [[ -z "$#" ]];then
        echo "域名不能为空"
        exit 2
    elif [[ $(echo "$1" | grep -E '^(\*|\w+)(\.)?\w+\.\w+$') != "$1" ]];then
        echo "域名格式为 www.example.com或example.com"
        exit 2
    else
        cert_dir="/usr/local/openresty/nginx/cert/$1"
        mkdir $cert_dir
        /root/.acme.sh/acme.sh --issue --dns dns_ali -d $1
        sleep 10
        /root/.acme.sh/acme.sh --install-cert -d $1 \
                        --key-file $cert_dir/key.pem \
                        --fullchain-file $cert_dir/cert.pem \
                        --reloadcmd "nginx -s reload"
    fi
else 
    echo "请输入一个域名"
    exit 2;
fi