#!/bin/bash
#mirror.rise.ph

systemctl disable firewalld.service --now
mkdir -pv /media/CentOS
sed -ri "s/(^SELINUX=).+/\1disabled/" /etc/selinux/config

cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LANGUAGE=en_US:en:zh_CN:zh
EOF

reboot

yum update -y
yum upgrade -y

reboot

yum install vim bash-completion epel-release yum-utils -y
#bash-completion-extras需要先安装epel
yum install bash-completion-extras
sed -ri "$ a set ts=4\nset paste\nset expandtab" /etc/vimrc

hostnamectl set-hostname centos9k8smaster1
nmcli connection modify ens160 ipv4.addresses 192.168.76.140/24
nmcli device reapply ens160