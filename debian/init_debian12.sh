#!/bin/bash
#init ubuntu

#network netplan

sed -ri  's@(iface ens33 inet )dhcp@\1static@' /etc/network/interfaces
sed -ri  '$ a address 192.168.76.252\nnetmask 255.255.255.0\ngateway 192.168.76.2 ' /etc/network/interfaces
systemctl restart networking

cp /etc/apt/sources.list{,.bak}
cat > /etc/apt/sources.list  << EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

apt install apt-transport-https ca-certificates bc -y
apt update
apt install vim lsof ntp ntpdate telnet lrzsz systemd-timesyncd -y
sed -ri "$ a set ts=4\nset expandtab\nset paste" /etc/vim/vimrc
sed -ri 's@(set mouse=).+@\1@g' /usr/share/vim/vim90/defaults.vim
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true


sed -ri 's@#(PermitRootLogin )prohibit-password@\1yes@' /etc/ssh/sshd_config
sed -ri 's/#(StrictModes yes)/\1/'  /etc/ssh/sshd_config
sed -ri 's/#(MaxAuthTries )6/\13/'  /etc/ssh/sshd_config
sed -ri 's/#(MaxSessions )10/\15/'  /etc/ssh/sshd_config
sed -ri 's/#(PasswordAuthentication yes)/\1/'  /etc/ssh/sshd_config

echo "root:/.,masdf" | chpasswd
hostnamectl hostname debian22model
sed -ri 's/(address 192.168.76.)[0-9]+/\1253/' /etc/network/interfaces

dpkg-reconfigure locales
cat > /etc/default/locale <<EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LANGUAGE=en_US:en:zh_CN:zh
EOF

localectl set-locale en_US.utf8
reboot