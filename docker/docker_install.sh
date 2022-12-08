#!/bin/bash
#最新版本docker 安装
sudo yum install -y yum-utils

if [ $(lsb_release -a | grep -i ^release | grep -oE '[0-9]') -eq 8 ];then
    sudo dnf config-manager \
	 --add-repo \
	 https://download.docker.com/linux/centos/docker-ce.repo
    else 
        sudo yum-config-manager \
            --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo	
fi
sudo yum install epel-release -y
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo alias docker-compose='docker compose'
sudo systemctl enable --now docker.service
#sudo curl -fsSL https://get.docker.com -o get-docker.sh | sh
