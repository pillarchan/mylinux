#!/bin/bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sleep 1
cat > /etc/yum.repos.d/elk.repo <<EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
yum repolist
yum makecache