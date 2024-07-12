#!/bin/sh
systemctl disable firewalld --now
iptables -F
setenforce 0
sed -ri 's@^\(SELINUX=\)\w*$@\1disabled@g' /etc/selinux/config 
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io docker-ce-20.10.24 docker-ce-cli-20.10.24 docker-compose
## 创建 /etc/docker 目录
mkdir /etc/docker
# 设置 Docker daemon
cat <<EOF | tee /etc/docker/daemon.json
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
mkdir -p /etc/systemd/system/docker.service.d
# 配置 containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 配置cgroupdriver
sed -ri 's/(SystemdCgroup = )false/\1true/' /etc/containerd/config.toml

# 配置ip_forward bridge-nf-call-iptables
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
# 重启docker服务
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
# 重启containerd服务
systemctl restart containerd

if [ $? -eq 0 ];then echo "docker install successfully"
fi
