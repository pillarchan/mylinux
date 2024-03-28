#!/bin/bash
#debian12 install

if [ $# -lt 1 ];then
	echo "请输入一个端口号"
	exit 2
fi

if [ $1 -lt 6379 -o $1 -gt 65535];then
	echo "端口值范围为6379-65535"
	exit 2
fi

#https://download.redis.io/releases/redis-7.0.14.tar.gz
#https://download.redis.io/releases/redis-6.2.14.tar.gz

PORT=$1
CPUS=$(lscpu | grep -E "CPU\(s\)" | sed -rn "1s/[^0-9]//gp")
THREADS=$(echo $CPUS-2|bc|awk '{print int($0)}')
MAXMEMORY=$(free -ml | grep -o -E "[0-9]+" | head -n1 | xargs echo 0.7* | bc | awk '{print int($0)}')
apt update
apt install make gcc gpg pkg-config automake autoconf libtool bc tcl -y
cd /usr/local/src
wget https://download.redis.io/redis-stable.tar.gz
tar -xzvf redis-stable.tar.gz
cd redis-stable
make -j $CPUS
make install
mkdir -pv /data/redis/$PORT
cp redis.conf /data/redis/$PORT/redis_$PORT.conf
sleep 1
sed -ri 's/^(bind\x20).+/\10.0.0.0/' /data/redis/$PORT/redis_$PORT.conf
sed -ri "s/^(port\x20)6379/\1${PORT}/" /data/redis/$PORT/redis_$PORT.conf
sed -ri "s/^(daemonize\x20)no/\1yes/" /data/redis/$PORT/redis_$PORT.conf
sed -ri "s/^(pidfile\x20)/var/run/redis_6379.pid/\1/data/redis/$PORT/redis_$PORT.pid/" /data/redis/$PORT/redis_$PORT.conf
sed -ri "s/^(logfile\x20)""/\1/data/redis/$PORT/redis_$PORT.log/" /data/redis/$PORT/redis_$PORT.conf
sed -ri '/^#\x20save\x20""/a save ""' /data/redis/$PORT/redis_$PORT.conf
sed -ri "s@^(dir\x20)\.\/@\1/data/redis/$PORT@" /data/redis/$PORT/redis_$PORT.conf
sed -ri 's@^(appendonly\x20)no@\1yes@' /data/redis/$PORT/redis_$PORT.conf
sed -ri '$ a #security \
requirepass "123456" \
rename-command FLUSHALL "" \
rename-command KEYS "" \
maxclients 1024 \
maxmemory ${MAXMEMORY}mb \
maxmemory-policy volatile-lru \
maxmemory-samples 5' \
/data/redis/$PORT/redis_$PORT.conf

/usr/local/redis/bin/redis-server /data/redis/$PORT/redis_$PORT.conf

echo 'export PATH="$PATH:/usr/local/redis/bin"' > /etc/profile.d/redis.sh
source /etc/profile.d/redis.sh

sysctl vm.overcommit_memory=1