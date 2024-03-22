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
#cd redis-stable/deps
#make fpconv
#make hdr_histogram
#make hiredis
#make jemalloc
#make linenoise
#make lua
cd redis-stable
make -j $CPUS
make install PREFIX=/usr/local/redis
cp redis.conf /usr/local/redis/redis.conf.default
mkdir -pv /data/redis/$PORT

cat > /data/redis/$PORT/redis.conf <<EOF
################################## NETWORK #####################################
bind 0.0.0.0
port $PORT
tcp-backlog 511 
timeout 0 
tcp-keepalive 60

################################# GENERAL #####################################
daemonize yes
loglevel notice 
databases 16
logfile "/data/redis/$PORT/redis_$PORT.log" 
pidfile /data/redis/$PORT/redis_$PORT.pid
always-show-logo no
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"
locale-collate ""

################################ SNAPSHOTTING(rdb)  ################################
save ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no
dir "/data/redis/$PORT"

################################# REPLICATION #################################
# replicaof <masterip> <masterport>
# masterauth <master-password>
# repl-ping-replica-period 10
#repl-timeout 60 
# repl-backlog-size 1mb
# min-replicas-to-write 3
# min-replicas-max-lag 10
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100


#security
protected-mode yes
requirepass "123456"
rename-command FLUSHALL "" 
rename-command KEYS ""
acllog-max-len 128

################################### CLIENTS ####################################
maxclients 1024

############################## MEMORY MANAGEMENT ################################
maxmemory ${MAXMEMORY}mb
maxmemory-policy volatile-lru
maxmemory-samples 5

############################# LAZY FREEING ####################################
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
lazyfree-lazy-user-del no
lazyfree-lazy-user-flush no
oom-score-adj no
oom-score-adj-values 0 200 800
disable-thp yes

################################ THREADED I/O #################################
# io-threads ${THREADS}

############################ KERNEL OOM CONTROL ##############################
oom-score-adj no
oom-score-adj-values 0 200 800

#################### KERNEL transparent hugepage CONTROL ######################
disable-thp yes

############################## APPEND ONLY MODE(aof) ###############################
appendonly no
appendfilename appendonly.aof
appendfsync everysec
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no

################################ REDIS CLUSTER  ###############################
#cluster-enabled yes
#cluster-config-file nodes-6379.conf
#cluster-node-timeout 15000
#cluster-slave-validity-factor 10
#cluster-migration-barrier 1
#cluster-allow-replica-migration yes
#cluster-require-full-coverage yes
# cluster-replica-no-failover no

################################## SLOW LOG ###################################
slowlog-log-slower-than 10000
slowlog-max-len 128

################################ LATENCY MONITOR ##############################
latency-monitor-threshold 0


#other
notify-keyspace-events ""
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
set-max-listpack-entries 128
set-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
EOF

/usr/local/redis/bin/redis-server /data/redis/$PORT/redis.conf

echo 'export PATH="$PATH:/usr/local/redis/bin"' > /etc/profile.d/redis.sh
source /etc/profile.d/redis.sh