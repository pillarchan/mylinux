#!/bin/bash
systemctl disable firewalld.service --now
mkdir -pv /media/CentOS
sed -ri "s/(^SELINUX=).+/\1disabled/" /etc/selinux/config
sed -ri "s/(^enabled=)0/\11/" /etc/yum.repos.d/CentOS-Media.repo
sed -ri "$ a mount -r /dev/sr0 /media/CentOS" /etc/rc.d/rc.local
chmod u+x /etc/rc.local
chmod u+x /etc/rc.d/rc.local
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