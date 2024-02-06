#!/bin/bash
#最新版本docker 安装
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do  apt-get remove $pkg; done

# Add Docker's official GPG key:
 apt-get update -y
 apt-get install ca-certificates curl -y
 install -m 0755 -d /etc/apt/keyrings
 curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
 chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
 apt-get update
sed -i 's@https://download.docker.com@https://mirrors.tuna.tsinghua.edu.cn/docker-ce@g' /etc/apt/sources.list.d/docker.list

 apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

cat > /etc/docker/daemon.json <<EOF
 {
    "registry-mirrors":["https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"]

 }
EOF


 systemctl enable --now docker.service
