#!/bin/bash

yum install -y lksctp* bzip2 python3 lrzsz* expect -y
yum install -y libaio-devel flex bison ncurses-devel glibc-devel patch redhat-lsb-core readline-devel -y

cat >> /etc/rc.local << EOF
if [ -e /sys/kernel/mm/transparent_hugepage/enabled ];then
	echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
fi
if [ -e /sys/kernel/mm/transparent_hugepage/defrag ];then
	echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
fi
EOF

cat >> /etc/hosts << EOF
192.168.76.201 centos76opengauss01
192.168.76.202 centos76opengauss02
192.168.76.203 centos76opengauss03
EOF


mkdir -pv /gauss/{soft,app,log,tmp,corefile,data}
mkdir -pv /gauss/data/{cm,dn}

