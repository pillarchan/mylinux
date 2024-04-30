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

