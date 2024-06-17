# redis基础命令

## 1.keys

```
keys *pattern*
```

## 2.scan cusor

```
scan 0
```

## 3.config get

```
config get *
config get *pattern*
```

## 4.config set

```
config set key value
```

## 5.expire key seconds

```
expire aaa 60
```

## 6.ttl 查看过期剩余时间

```
ttl key
```

## 7.persist 终止过期时间

```
persist key
```

## 8.exists

```
exists key
```

## 9.rename

```
rename key newname
```

## 10.del key

## 11.setect 1

## 12.flushdb

## 13.flushall

## 14.randomkey

## 15.type

# redis数据类型和应用场景

## 1.string 字符型

``` 
set key value 
get key
set key value ex
incr key
decr key
mset key value key value
msetnx key value key value 如果key不存在则添加成功
append key value
setrange key offset value
getrange key start end
strlen
应用场景：
session
计数
```

## 2.hash

```
hset key field value 
hgetkey field
hmset key field value [field value...] 
hmget key field [field...]
hgetall
hlen
hkeys
hvals
hexists key field
hstrlen key field
hdel key field [field...]
hincrby key field
应用场景：
用户信息、账户信息等
```

## 3.list

```
rpush key
lpush key
linsert key before|after pivot value
rpoplpush key1 key2

lpop key
rpop key
lrem key count value
ltrim key start end
blpop key
brpop key

lrange key start end
lindex key index
llen key

lset key index newValue
应用场景：
消息列队，评论，文章列表
```

## 4.set

```
Redis的Set是string类型的⽆序集合。它底层其实是⼀个value为null的hash表，所以添加，删除，查找的复杂度都是O(1)。
⼀个算法，随着数据的增加，执⾏时间的⻓短，如果是O(1)，数据增加，查找数据的时间不变
#集合内操作
（1）添加元素，返回结果为添加成功的元素个数
sadd key member [member ...] 
（2）删除元素，返回结果为成功删除元素个数
srem key member [member ...] 
（3）计算元素个数
scard key 
（4）判断元素是否在集合中
sismember key member 
（5）随机从集合返回指定个数元素，不会删除
srandmember key [count] #[count]是可选参数，如果不写默认为1
（6）随机从集合弹出元素删除
spop key [count] 
（7）获取所有元素
smembers key 
# 集合间操作
（1）求多个集合的交集
sinter key [key ...]
（2）求多个集合的并集
suinon key [key ...]
（3）求多个集合的差集
sdiff key [key ...] #key1中的，不包含key2中的
（4）将交集、并集、差集的结果保存
sinterstore destination key [key ...]
suionstore destination key [key ...]
sdiffstore destination key [key ...]
（5）将集合中⼀个member移动到另⼀个集合
smove source destination member

应用场景：
标签，共同好友，独立ip
```

## 5.zset （Sorted set）有序集合

```
1. Redis有序集合zset与普通集合set⾮常相似，是⼀个没有重复元素的字符串集合。
2. 有序集合的每个成员都关联了⼀个评分（score）,这个评分（score）被⽤来按照从最低分到最⾼分的⽅式排序集
合中的成员。集合的成员是唯⼀的，但是评分可以重复
3. 元素有序，根据评分（score）或者次序（position）来获取⼀个范围的元素。
4. 访问有序集合的中间元素也是⾮常快的,因此你能够使⽤有序集合作为⼀个没有重复成员的智能列表。


#集合内操作
（1）添加成员
zadd key score member [score member ...] 
zincrby key increment member #增加成员的分数
（2）查看成员个数
zcard key
（3）查看某个成员的分数
zscore key member
（4）查看成员的排名
zrank key member #从分数从低到⾼返回排名，
zrevrank key member #zrevrank从分数从⾼到低返回排名
（5）返回指定排名范围的成员
zrange key start end [withscores] #从低到⾼
zrevrange key start end [withscores] #从⾼到低 
（6）返回指定分数范围的成员 
zrangebyscore key min max [withscores] [limit offset count] #从低到⾼
zrevrangebyscore key max min [withscores] [limit offset count] #从⾼到低 
说明：min和max还⽀持开区间（⼩括号）和闭区间（中括号），-inf和 +inf分别代表⽆限⼩和⽆限⼤
（7）返回指定分数范围成员个数
zcount key min max
（8）删除成员
zrem key member [member ...]
（9）删除指定排名内的升序元素
zremrangebyrank key start end
（10）删除指定分数范围的成员
zremrangebyscore key min max
#集合间的操作
（1）交集
zinterstore destination numkeys key [key ...] [weights weight [weight ...]] [aggregate sum|min|max]
 · destination：交集计算结果保存到这个键。
 · numkeys：需要做交集计算键的个数。
 · key[key...]：需要做交集计算的键
 · weights weight[weight...]：每个键的权重，在做交集计算时，每个键中 的每个member会将⾃⼰分数乘以这个权重，每个键的权重默认是1。
 · aggregate sum|min|max：计算成员交集后，分值可以按照sum（和）、 min（最⼩值）、max（最⼤值）做汇总，默认值是sum。
（2）并集
zunionstore destination numkeys key [key ...] [weights weight [weight ...]] [aggregate sum|min|max]
应用场景
排行榜，社交网络
```

## 6.bitmap

```
- bitmap 是位图数据结构，只有0 和 1 两个状态
- Bitmaps本身不是⼀种数据类型， 实际上它就是字符串（key-value），但是它可以对字符串的位进⾏操作
setbit key offset value
getbit key offset
bitcount key
应用场景：
⽹络流量分析
签到
布隆过滤器
活跃⽤户统计
```

# redis事务操作

## Redis 事务的特性

redis的事务只是保证了多条命令的串⾏执⾏

并不能保证执⾏命令的原⼦性

redis事务只有在⼊队异常的时候会回滚,进⼊server执⾏并不会回滚

## 1.开启事务

```
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> set a 123456
QUEUED
127.0.0.1:6379(TX)> set b 654321
QUEUED


```

## 2.执行事务

```
127.0.0.1:6379(TX)> EXEC
1) OK
2) OK
```

## 3.取消事务执行（回滚）

```
127.0.0.1:6379(TX)> set a 11111
QUEUED
127.0.0.1:6379(TX)> discard
OK
```

# redis的主从复制

## 1.主从同步的原理

```
主从复制过程⼤体可以分为3个阶段：
- 连接建⽴阶段（即准备阶段）
	主从redis服务器搭建完成后,从服务器可以使用slaveof命令或者通过配置slaveof与主服务器建立主从关系，此时就开启了主从复制。
	- 从节点保存主节点（master）信息。
	- 建⽴Socket连接
	- 发送PING命令
	- 权限验证	
- 数据同步阶段
	全量数据同步：
	主从复制开启后，从服务器发送psync请求到主服务器，主服务接收到请求后执行bgsave生成rdb文件并发送给从服务器。从服务收到rdb文件后，先清理掉自己的旧数据，加载rdb中的信息，完成全量数据同步
- 命令传播阶段
	增量数据同步：
	全量数据同步完成后，主服务器如有新的写操作命令会持续转发给从服务器，从服务器执行命令完成增量同步

从服务器故障恢复后，重连主服务器并发送psync给主服务器，主服务器根据请求计算偏移量，将从服务器缺失部分的进行同步

psync命令运⾏需要以下组件⽀持：
- 主从节点各⾃复制偏移量
- 主节点复制积压缓冲区
- 主节点运⾏id
```

## 2.配置

```
slaveof <masterip> <masterport> #添加从节点
slave-serve-stale-data yes #同步数据期间，是否可使⽤陈旧数据向客户端提供服务
slave-read-only yes
repl-diskless-sync no #⽆盘复制适⽤于主节点所在机器磁盘性 能较差但⽹络带宽较充裕的场景*/
repl-diskless-sync-delay 5 #两次diskless模式的数据同步操作的时间间隔
repl-ping-slave-period 10 #Slave节点向Master节点发送ping指令的事件间隔,10s
repl-timeout 60 #Master和Slave之间的超时时间
repl-disable-tcp-nodelay no #主从复制时使⽤的⽹络资源优化参数
默认关闭
关闭:所有命令数据发送从节点,延迟变少,但是⽹络带宽消耗增加。适合同机房
开启:合并较⼩tcp数据包,默认40ms，节省带宽增⼤主从延时，适合跨机房部署
repl-backlog-size 1MB #主节点复制积压缓冲区⼤⼩
slave-priority #当前Slave节点的优先级权重
min-slaves-to-write和min-slaves-max-lag #拒绝数据写操作的策略
```

## 3.常用命令

```
info replication #查看主从
slaveof masterip masterport #建立主从
slaveof no one #取消主从
```

# redis哨兵

## 	1.概念 

Redis哨兵是一种高可用解决方案，通过监控主从节点的健康状态，并在主节点出现故障时自动将其替换为从节点，从而确保Redis集群的持续可用性。

## 	2.实现

### 		1.配置

```
cat > /data/redis/sentinel/sentinel.conf << EOF
bind 192.168.76.250 127.0.0.1
port 16379
daemonize yes
pidfile "/data/redis/sentinel/redis-sentinel.pid"
logfile "/data/redis/sentinel/redis-sentinel.log"
dir "/data/redis/sentinel"
sentinel monitor mymaster 192.168.76.250 6379 2
sentinel auth-pass mymaster 123456
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 180000
EOF
```

## 		2.启动

```
redis-sentinel sentinel.conf
或
redis-server sentinel.conf --sentinel
```

## 	3.原理

​	服务监听->主客观下线->选举->故障切换

### 			1.三个定时任务

​		每10秒发送一次 info 获取 redis 拓扑 每2秒发送一次哨兵订阅节点，保证新加哨兵的保存信息和消息交换 每1秒向所有redis和哨兵发送ping用来心跳检测

### 			2.主客观下线

​		每隔一秒就对主 从 sentinel 服务检测，如果超过down时间就认定主观下线，如果主观下线认定是master，则和其它哨兵进行投票，投票通过做出客观下线

### 			3.选举

​		当客观下线完成，sentinel会选择一个leader对redis进行故障转移

### 	4.故障转移

​		在从节点列表中进行过滤优先选择优先级别高的作为主节点，如果优先值一样则选择复制偏移量最大的，如果复制偏移量一样则选择runid最小值的。选出新主之后，哨兵leader对新主重新做 replication of，其余的从节点再重新同步新主，最后整理redis拓扑关系

## 4.管理命令

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

# redis cluster

## 1.概念

redis cluster是一种高可用的分布式存储方式，采用的是hash虚拟槽分区，主要解决的是单机内存、并发和流量瓶颈问题。

### hash虚拟槽分区

```
基于⼀致性hash优化
把所有数据映射到⼀个固定范围的整数集合,定义为slots，为迁移和管理的基本单位
使用16384个槽位
```

### redis分区

```
采⽤虚拟slot分区,计算共识 slot=CRC16(key)&16384 每个节点负责维护⼀部分槽
Redis slot特点:
1.简化扩缩容难度
2.仅维护slot和节点及key的映射查询即可
3.不需要客户端或者代理服务
功能限制:
1.key批量操作有限:mset or mget，以为不同slot的key在多个节点不⽀持
2.事务操作有限:多个节点涉及分布式事务
3.⼤key⽀持不好:⼀个⼤hash仅能分配到⼀个slot
4.集群仅使⽤db0
5.不⽀持级联复制
```

### 为什么使用16384个槽

```
1. 正常的⼼跳数据包携带节点的完整配置，它能以幂等⽅式来更新配置。如果采⽤ 16384 个插槽，占空间 2KB（16384/8）；如果采⽤ 65536 个插槽，占空间 8KB (65536/8)。
2. Redis Cluster 不太可能扩展到超过 1000 个主节点，太多可能导致⽹络拥堵。
3. 槽位越⼩，节点少的情况下，压缩率⾼
```



## 2.部署

# 面试相关

## 1.rdb和aof的区别

```
两者都是用于持久化redis数据的
rdb 是基于快照的方式做持久化，速度更快，一般用做备份，主从复制也是依赖于rdb
aof 是以追加的方式记录redis的操作日志，最大程度上保证数据不丢失，类似于mysql的binlog日志
Redis 启动时，如果同时存在 RDB 和 AOF 文件，**优先读取 AOF 文件**来恢复数据。
```

## 2.当缓存服务构建主从环境后，是否还需要开启缓存服务的持久化存储功能?

```
还是需要开启，主从复制依赖于rdb持久化
主缓存服务一旦出现宕机，内存中数据都会出现丢失，并且主库恢复上线后，会将空的内存状态同步给从库，
所以，如果不开启持久化功能，一旦主库宕机，就不要让主库再次恢复主从同步关系
```

## 3.在实现高可用后，如何保证业务能正常访问

```

```

## 4.Redis Cluster 使用 16384 个槽位的原因主要有以下几点：

- **心跳包大小**：Redis Cluster 的每个节点都会定期向其他节点发送心跳包，以维护集群状态。心跳包中包含的信息包括节点的配置信息，例如节点 ID、负责的槽位等。如果槽位数过多，则会导致心跳包的大小增加，从而增加网络带宽的消耗。
- **集群规模**：在实际应用中，Redis Cluster 的集群规模通常不会超过 1000 个节点。如果槽位数过多，则会导致每个节点管理的槽位数量减少，从而降低集群的整体性能。
- **压缩率**：Redis Cluster 使用 CRC16 算法将键映射到槽位。CRC16 算法可以生成 16 位的哈希值，因此 Redis Cluster 使用 16384 个槽位可以最大限度地提高压缩率。

具体来说，Redis Cluster 的心跳包中包含一个位图，用于表示节点负责的槽位。如果槽位数为 16384，则可以使用 2048 个字节来表示该位图。如果槽位数为 65536，则需要使用 8192 个字节来表示该位图。在集群规模较小的情况下，使用 2048 个字节的位图可以显著提高压缩率。

此外，Redis Cluster 的每个节点都会维护一个槽位表，用于记录每个槽位对应的节点。如果槽位数过多，则会导致槽位表的大小增加，从而增加节点的内存消耗。

综上所述，Redis Cluster 使用 16384 个槽位可以平衡心跳包大小、集群规模、压缩率和内存消耗等因素，从而获得较好的性能和可用性。