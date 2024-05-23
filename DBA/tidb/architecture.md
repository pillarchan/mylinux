# TIDB体系架构

##  主体架构

### 访问流程

application msyql protocol -> tidb cluster -> PD cluster -> kv cluster

###  水平扩容或缩容

主要是针对于tidb存储节点

tidb 数据库主要是解决mysql分库分表

扩容要考虑服务器配置的一致性

#### tikv 扩缩容

基于节点管理数，一个tikv节点 管理3万个region 是比较合理的

缩容看并发使用 tikv的负载

### 金融级高可用

指MVCC支持事务的ACID

副本数至少为5个

### 实时HTAP

指行存tikv 负责 oltp的需求,列存tiflash负责olap的需求，两者相互隔离

tikv底层的存储块就是每个96M的region

region基于raft数据同步或者一个状态机，状态机就会有角色分为 leader flower learner,其中leader承担读写，flower用于接收事务日志、redo日志并且应用，而且必须多副本应用后才能提交的，learner是异步同步的

### 云原生的分布式数据库

与k8s做了绑定，可以直接在k8s中拉起tidb集群

### 兼容mysql5.7协议

## TIDB Server

### 处理客户端连接

### SQL语句的解析和编译，生成执行计划

### 关系型二维表数据与kv的转化

### SQL语句的执行

​	生成执行计划，调用tikv，在tidb计算层做计算

### 执行online DDL

​	表的在线变更，比如加字段，加索引，在5.7之前是需要copy table。如果使用pt_change_schema的工具，表过大也会造成写慢或者写锁

tidb online ddl 可以做到无感，它是后台异步执行online ddl对表进行字段、索引的修改

### 垃圾回收（tidb的角色）

tidb里面有一个mysql tidb的表，tikv的存储引擎是lsmtree，是不会在原来的数据上进行修改的，当新写数据，它就会新生成一条数据，这样每条数据都会有一个MVCC版本，每个版本就是一条全行数据，这就导致要如何去控制这些版本。

tidb就是通过 tidb_gc_life_time，它是一个10分钟的控制，造成10分钟的MCVV版本就会自动标识并回收，可以通过 select tidb_stamp_sort在某个时间戳内的表数据

## TIKV

### 概念

一般tikv要用到三个副本，部署的就至少需要3个tikv节点，每个节点存储region的peer，3个peer组成一个region raft group。每个tikv里面包括事务层、MVCC、RAFT基于raft日志做数据复制。每个tikv会管理两个rocksdb，一个用于存储raft日志，一个用于存储数据。而在7.0版本之后一个tikv就是管理多个rocksdb，这样就可以达到更多的扩展，提升读写性能。

### 数据持久化

传统mysql数据持久化，数据会存3份，redolog、binlog、idb文件，而tidb是会2份，一个是redo日志，另一个则是kv数据

### 副本的强一致性和高可用性

当tidb写入一条数据，最终会在tikv节点落盘，当数据写入时通过raft日志将数据同步到其它节点，并且还要保证多数节点写入成功，也就说如果是三个节点至少两个节点写入成功，才会做事务提交

### MVCC(多版本控制)

tidb使用的是lsmtree存储引擎，当写数据时，不会在原有的数据上进行覆盖，而是新写一条的行数据，里面就有MVCC的版本，当时MVCC事务还未提交时，其它的session是不能该做修改的，而新的session读取该数据时，是读取最新版本的数据，这样可以实现一致性读，可重复读

### 分布式事务支持

当数据进行写操作时，而数据存储在不同节点时，事务对不同节点上的数据进行修改操作，这就是分布式事务

### Coprocessor(算子下推)

是指将计算任务下推到存储层执行，而不是将数据传输到计算节点进行处理。比如：执行了一条查询语句，而这些数据在不同的tikv节点，那么coprocessor就会将必要的数据找出后再传到tidb计算层，从而减少tidb的计算，提高查询效率

## Placement Driver(PD)

### 事务操作

strorage cluter(TIKV,TiFlash)->心跳->PD->TSO,分布式信息->TiDB Server

PD事务相关，PD会分配TSO，当一个SQL语句做了事务操作，去请求PD获取时间戳，当事务开启时会有一个start_ts，提交后会有一个commit_ts，在这两个ts之前可以做到事务隔离

### 调度操作

strorage cluter(TIKV,TiFlash)->心跳->PD->调度操作->strorage cluter(TIKV,TiFlash)

整体store心跳汇报给pd，包括total size,接受心跳的频率，整体的流量，整体CPU、内存、负载，另外store里包括了有很多region，这些region的访问信息也会汇报给PD，当某个tikv节点某些region过热时，PD会根据上传的信息对过热的TIKV进行leader transfer，让其它tikv节点参与并均衡这个TIKV的region。

当Tiflash去Tikv同步时，需要知道要同步哪些数据，也是需要和PD交互，需要收集tikv leader的数据写入到Tiflash

### 功能

#### 整个集群TIKV的元数据存储

tikv会实时汇报整体信息包括region信息到PD，PD会将这些元数据信息存到底层的etcd里面，这些元数据信息都被TIDB server在查询sql时所依赖

#### 分配全局ID和事务ID

全局ID指的是分配给每个表的唯一ID

#### 生成全局时间戳TSO

#### 收集集群信息进行调度

tikv把自身整体的信息主动上报给PD，PD将收集的到信息存到底层ETCD，生成元信息，再根据这些元信息进行调度

#### 提供TIDB Dashboard服务

## TiFlash

### 列存引擎

可以做到物理层面的隔离，当tikv的一个表列为tiflash的一个同步表，tikv上的数据就和tiflash是同步的，tiflash是通过异步的方式去同步tikv上的数据

### 异步复制

当一个oltp写入，不会等TiFlash同步完成之后才提交，而是只要Tikv多数副本写入成功就会提交

### 一致性

一个tikv节点的数据通过ratf日志同步到其它tikv节点或者tiflash节点是一样的

### 列式存储提高分析查询效率

Tiflash是基于clickhouse的引擎实现的，clickhouse的单机性能是非常强的

### 业务隔离

olap 查询 tiflash kv时不会影响tikv，但是最好把tidb server也进行隔离，如果共用一个tidb server，而读取tiflash数据过大就会影响，那所有banlance通过lb过来的oltp业务就会和olap业务争抢资源

### 智能选择

当业务请求一个复杂sql的时候，通过查询优化器，去选择tikv或者是tiflash，比如一个二级索引或唯一索引过滤就默认走tikv，如果是一个全表的group by 就默认走tiflash，它会基于cpu算法做智能选择，tikv和tiflash也可以互相搭配，先通tikv过滤再过tiflash计算会更快

## 小彩蛋

持久化是持久化tikv,tidb server是计算