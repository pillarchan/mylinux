#!/bin/bash
#init ubuntu

#network netplan

cat > /etc/netplan/00-installer-config.yaml  << EOF
network:
  renderer: networkd
  ethernets:
    ens33:
      dhcp6: false
      addresses: 
        - 192.168.76.253/24
      gateway4: 192.168.76.2
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
  version: 2	  
EOF
netplan apply

cp /etc/apt/sources.list{,.bak}
cat > /etc/apt/sources.list  << EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF

apt update
apt install vim bash-completion lsof ntp ntpdate telnet systemd-timesyncd lrzsz apt-utils -y
sed -ri "$ a set ts=4\nset expandtab\nset paste" /etc/vim/vimrc
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true


sed -ri 's@#(PermitRootLogin )prohibit-password@\1yes@' /etc/ssh/sshd_config
sed -ri 's/#(StrictModes yes)/\1/'  /etc/ssh/sshd_config
sed -ri 's/#(MaxAuthTries )6/\13/'  /etc/ssh/sshd_config
sed -ri 's/#(MaxSessions )10/\15/'  /etc/ssh/sshd_config
sed -ri 's/#(PasswordAuthentication yes)/\1/'  /etc/ssh/sshd_config

echo "root:/.,masdf" | chpasswd
hostnamectl hostname ubuntu22model

apt install language-pack-en language-pack-zh-hans -y
cat > /etc/default/locale <<EOF
LANG=en_US.UTF-8
LANGUAGE=en_US:en:zh_CN:zh
EOF

localectl set-locale en_US.utf8
reboot