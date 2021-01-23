#!/bin/sh
sudo sed -i '$ a set nu\nset ts=4\nset expandtab\nset nohlsearch' /etc/vimrc
sudo systemctl restart chronyd
sudo systemctl enable chronyd
sudo timedatectl set-timezone Asia/Shanghai 
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo iptables -F
sudo setenforce 0
sudo sed -i 's@^\(SELINUX=\)\w*$@\1permissive@g' /etc/selinux/config 
sudo yum update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io docker-ce-19.03.11 docker-ce-cli-19.03.11 
## 创建 /etc/docker 目录
sudo mkdir /etc/docker
# 设置 Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
# Create /etc/systemd/system/docker.service.d
sudo mkdir -p /etc/systemd/system/docker.service.d
# 配置 containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 配置cgroupdriver
sudo sed -i '/options/ a \\t\t\t\t SystemdCgroup = true' /etc/containerd/config.toml

# 重启docker服务
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
# 重启containerd服务
sudo systemctl restart containerd

if [ $? -eq 0 ];then echo "docker install successfully"
fi