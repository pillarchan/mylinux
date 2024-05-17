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

​	服务监听->主客观下线->选举->故障切换

#### 			1.三个定时任务

​		每10秒发送一次 info 获取 redis 拓扑 每2秒发送一次哨兵订阅节点，保证新加哨兵的保存信息和消息交换 每1秒向所有redis和哨兵发送ping用来心跳检测

#### 			2.主客观下线

​		每隔一秒就对主 从 sentinel 服务检测，如果超过down时间就认定主观下线，如果主观下线认定是master，则和其它哨兵进行投票，投票通过做出客观下线

#### 			3.选举

​		当客观下线完成，sentinel会选择一个leader对redis进行故障转移

#### 	4.故障转移

​		在从节点列表中进行过滤优先选择优先级别高的作为主节点，如果优先值一样则选择复制偏移量最大的，如果复制偏移量一样则选择runid最小值的。选出新主之后，哨兵leader对新主重新做 replication of，其余的从节点再重新同步新主，最后整理redis拓扑关系

### 4.管理命令

​	1. sentinel masters #展示所有被监控的主节点状态以及相关的统计信息

```
127.0.0.1:26410> sentinel masters
```

​	2. sentinel master \<master name\> #展示\<master name\> 的主节点状态以及相关的统计信息

```
127.0.0.1:26410> sentinel master mymaster
```

​	3. sentinel slaves \<master name\> #展示指定\<master name\>的从节点状态以及相关的统计信息

```
127.0.0.1:26410> sentinel slaves mymaster
```

​	4. sentinel sentinels \<master name\> #展示指定\<master name\>的Sentinel节点集合（不包含当前Sentinel节点）

```
127.0.0.1:26410> sentinel sentinels mymaster
```

​	5. sentinel get-master-addr-by-name \<master name\> #返回\<master name\>主节点的IP地址和端⼝

```
127.0.0.1:26410> sentinel get-master-addr-by-name mymaster
```

​	6. sentinel reset \<pattern\> #对符合条件的主节点的配置进⾏重置

​	7. sentinel failover \<master name\> #对指定\<master name\>主节点进⾏强制故障转移（没有和其他Sentinel节点“协商”）

​	8. sentinel ckquorum \<master name\> #检测当前可达的Sentinel节点总数是否达到\<quorum\>的个数。

```
例如 quorum=3，⽽当前可达的Sentinel节点个数为2个，那么将⽆法进⾏故障转移，Redis Sentinel的⾼可⽤特性也将失去
```

​	9. sentinel flushconfig #将Sentinel节点的配置强制刷到磁盘上

​	10. sentinel remove \<master name\> #取消当前Sentinel节点对于指定 \<master name\>主节点的监控

​	11. sentinel monitor \<master name\> \<ip\> \<port\> \<quorum\>

​	12. sentinel set \<master name\> #动态修改Sentinel节点配置选项

​	13. sentinel is-master-down-by-addr 

