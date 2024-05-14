# redis

## 哨兵模式

### 	1.概念 

Redis哨兵是一种高可用解决方案，通过监控主从节点的健康状态，并在主节点出现故障时自动将其替换为从节点，从而确保Redis集群的持续可用性。

### 	2.实现

#### 		1.配置

```
cat > /data/redis/sentinel/sentinel.conf << EOF
bind 192.168.76.170 127.0.0.1
port 16400
daemonize yes
pidfile /data/redis/sentinel/sentinel.pid
logfile "/data/redis/sentinel/sentinel.log"
dir /data/redis/sentinel/
sentinel monitor mymaster 192.168.76.170 6400 2
sentinel auth-pass mymaster 123456
sentinel down-after-milliseconds mymaster 3000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 10000
EOF
```

#### 		2.启动

```
redis-sentinel sentinel.conf
或
redis-server sentinel.conf --sentinel
```

### 	3.原理

​	监听->主客观下线->选举->故障切换

#### 		1.三个定时任务

​		每10秒发送一次 info 获取 redis 拓扑 每2秒发送一次哨兵订阅节点，保证新加哨兵的保存信息和消息交换 每1秒向所有redis和哨兵发送ping用来心跳检测

#### 		2.主客观下线

​		每隔一秒就对主 从 sentinel 服务检测，如果超过down时间就认定主观下线，如果主观下线认定是master，则和其它哨兵进行投票，投票通过做出客观下线，再选择一个哨兵进行failover

#### 		3.选举

