#!/bin/bash

yum install wget -y
cd /usr/local/src
wget -O https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz 
tar xf kafka_2.13-3.7.0.tgz -C ../ln -sv kafka_2.13-3.7.0/ kafka
cat > /etc/profile.d/kafka.sh << 'EOF'
export KAFKA_HOME="/usr/local/kafka"
export PATH="$PATH:$KAFKA_HOME/bin"
EOF

