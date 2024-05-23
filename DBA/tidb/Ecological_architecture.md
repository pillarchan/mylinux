# TIDB生态架构

## TIDB

是一个存算分离的一个架构，指的是存储和计算分离，参考是google spanner的架构。

### 计算层

是tidb cluster 负责接收sql请求，解析，编译，分成执行计划，调用底层接口去读写想要存储的数据

TIDB是无状态的，可以非常平滑地扩缩容，去支持更多的数据吞吐 

### 存储

主要是依据KV cluster 主要是分为两种存储引擎 

一种是属于行存，偏交易类的行存 叫TIKV，是基于RocksDB，通过节点或集群处理交易数据的存储 raft log

一种是属于列存，TIFlash基于ClickHouse 

### PD cluster 

相当于TIDB的大脑，底层基于ETCD

1.源信息管理中心，存储了要查询数据的location，比如访问哪些表，存在哪些节点上

2.是一个调度中心，发送调度指令，根据TIKV或TIFlash上传的心跳信息，做数据的统计分布，对region 上传的心跳信息做region切换，做fail over，以及读写热点的切分,transfer等

3.PD底层是存的数据，元数据信息，根据请求语句和PD元数据信息找到数据存储的leader节点，而元数据信息来自于KV的元数据心跳上报，心跳上报的其中一个是store,就是一个tikv的整体节点，另一个就是region信息，比如哪些region、region id、流量情况、数据size等，供PD调度

4.全局ID生成器，比如表ID，自增ID，还会生成全局事务的时间戳

DissSQL主要是针对于复杂查询，比如group by，

KV API 主要是点查，比如索引查询

## 数据迁移 

MYSQL -> BINLOG -> DM MASTER -> TIDB

## DBDAS 平台

1. meta info
2. DB failover
3. config manager
4. deployment
5. monitor report
6. sql audit
7. scale in/out
8. auto manager

## 部署

1. TIUP
2. TIDB Ansible
3. TiBigdata 离线数据抽取
4. TiRedis
5. TiFlink
6. JuiceFS

## K8S

TIDB operator

## ELK 日志分析 

filebeat->kafka->logstash->es->kibana

slowlog

errorlog

## 监控报警

prometheus->collection->send alter

grafana

TIDB exporter

TIDB monitor

## 备份/恢复

Dumping 逻辑备份

BR 物理备份

Lightning 导入迁移工具

## TICDC 

TICDC cluster -> kafka ->s3或 tidb cluster

数据同步