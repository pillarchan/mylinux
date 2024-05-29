#!/bin/bash
yum install wget -y
cd /usr/local/src
tar xf jdk-8u391-linux-x64.tar.gz -C ../
tar xf apache-zookeeper-3.8.2-bin.tar.gz -C ../
cd ../
ln -sv apache-zookeeper-3.8.2-bin/ zookeeper

cat > /etc/profile.d/zookeeper.sh << 'EOF'
export ZOOKEEPER_HOME="/usr/local/zookeeper"
export PATH="$PATH:$ZOOKEEPER_HOME/bin"
EOF

cat > /etc/profile.d/java.sh << 'EOF'
export JAVA_HOME="/usr/local/jdk1.8.0_391"
export PATH="$PATH:$JAVA_HOME/bin"
EOF

source /etc/profile
