#!/bin/bash
#最新版本docker 安装
sudo yum install -y yum-utils
sudo yum install redhat-lsb-core -y
if [ $(lsb_release -a | grep -i ^release | grep -oE '[0-9]') -eq 8 ];then
    sudo dnf config-manager \
	 --add-repo \
	 https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
else 
    sudo yum-config-manager \
        --add-repo \
    https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo	
fi
sed -i 's@https://download.docker.com@https://mirrors.tuna.tsinghua.edu.cn/docker-ce@g' /etc/yum.repos.d/docker-ce.repo
sudo yum install epel-release -y
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
				docker-*
sudo systemctl disable --now docker.service
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y
sudo alias docker-compose='docker compose'

#sudo curl -fsSL https://get.docker.com -o get-docker.sh | sh

mkdir -pv /etc/docker
cat > /etc/docker/daemon.json <<EOF
 {
    "registry-mirrors":["https://dockerproxy.com","https://mirror.baidubce.com","https://docker.nju.edu.cn"]

 }
EOF


sudo systemctl enable --now docker.service
