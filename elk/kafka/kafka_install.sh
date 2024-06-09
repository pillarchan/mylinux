#!/bin/bash
yum install wget -y
cd /usr/local/src
wget -O https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz 
tar xf kafka_2.13-3.7.0.tgz -C ../
tar xf jdk-8u391-linux-x64.tar.gz -C ../
cd ../
ln -sv kafka_2.13-3.7.0/ kafka

cat > /etc/profile.d/kafka.sh << 'EOF'
export KAFKA_HOME="/usr/local/kafka"
export PATH="$PATH:$KAFKA_HOME/bin"
EOF

cat > /etc/profile.d/java.sh << 'EOF'
export JAVA_HOME="/usr/local/jdk1.8.0_391"
export PATH="$PATH:$JAVA_HOME/bin"
EOF

source /etc/profile

