# oceanbase

## oceanbase 架构

应用 -> 域名 -> VIP -> obproxy -> observer              prometheus  Grafana  ob-express

oceanbase 分布式数据库采用shard-nothing 架构, 数据库内的sql执行引擎具有分布式执行能力

### observer 

observer  是oceanbase服务器上运行的一个单进程实例，使用本地的文件来存储**数据**和**事务redo log 日志**

###  zone

 可用区 部署集群时需要用到一个可用区，由若干服务器组成，可以在同一机房，机架，同一内网

### 副本

存储的数据在分布式集群内部可以存储到多个副本，用于**容灾**和**分散读取压力**，在一个可用区内部数据只有一个副本，不同的可用区可以存储同一个数据的多个副本，**副本之间由共识协议保证数据的一致性**。

### 多租户特性

OceanBase 内置多租户特性，**每个租户对于使用者是一个独立的数据库**，一个租户能**够在租户级别设置租户的分布式部署方式**。租户之间 **CPU、内存和 IO** 都是隔离的。

### OceanBase的数据库实例组件

OceanBase的数据库实例内部由不同的组件相互协作，这些组件从底层向上由**存储层、复制层、均衡层、事务层、SQL 层、接入层**组成。

#### 存储层

具有存储一张表的数据或者一个分区数据的能力。

**以一张表或者一个分区为粒度**提供数据存储与访问，**每个分区对应一个用于存储数据的Tablet（分片）**，用户定义的非分区表也会对应一个 Tablet。Tablet 的内部是分层存储的结构，总共有 4 层。MemTable、L0SSTable、L1SSTable、MajorTable。

DML 操作插入、更新、删除等首先写入MemTable，等到 MemTable 达到一定大小时转储到磁盘成为 L0 SSTable。

L0 SSTable 个数达到阈值后会将多个 L0 SSTable 合并成一个 L1 SSTable。

在每天配置的业务低峰期，系统会将所有的 MemTable、L0 SSTable 和 L1 SSTable 合并成一个 Major SSTable。

每个 **SSTable 内部是以 2 MB 定长宏块**为基本单位，每个宏块内部由多个不定长微块组成。

**Major SSTable 的微块会在合并过程中用编码方式进行格式转换**，微块内的数据会按照列维度分别进行列内的编码，编码规则包括字典/游程/常量/差值等，每一列压缩结束后，还会进一步对多列进行列间等值/子串等规则编码。**编码能对数据大幅压缩**，同时提炼的列内特征信息还能进一步加速后续的查询速度。

在编码压缩之后，还可以根据用户指定的通用压缩算法进行无损压缩，进一步提升数据压缩率。

#### 复制层

使用共识算法保证一个分区的不同副本之间数据的一致性

复制层**使用日志流（LS、Log Stream）在多副本之间同步状态**。每个 Tablet 都会对应一个确定的日志流，DML 操作写入 Tablet 的数据所产生的 Redo 日志会持久化在日志流中。**日志流的多个副本会分布在不同的可用区中，多个副本之间维持了共识算法，选择其中一个副本作为主副本，其他的副本皆为从副本**。Tablet 的 DML 和强一致性查询**只在其对应的日志流的主副本上进行**。

通常情况下，每个租户在每台机器上只会有一个日志流的主副本，可能存在多个其他日志流的从副本。**租户的总日志流个数取决于 primary_zone 和 locality 的配置**。

日志流使用自研的 Paxos 协议将 Redo 日志在本服务器持久化，同时通过网络发送给日志流的从副本，从副本在完成各自持久化后应答主副本，主副本在确认有多数派副本都持久化成功后确认对应的 Redo 日志持久化成功。从副本利用 Redo 日志的内容实时回放，保证自己的状态与主副本一致。       日志流 -> 主副本持久化redolog -> 从副本 -> 主副本确认多数从副本已持久化 -> 从副本回放redolog同步数据

日志流的主副本在被选举成为主后会获得**租约（Lease**），正常工作的主副本在租约有效期内会不停的通过选举协议延长期租约。主副本只会在租约有效时执行主的工作，租约机制保证了数据库异常处理的能力。

复制层能够自动应对服务器故障，保障数据库服务的持续可用。如果出现少于半数的从副本所在服务器出现问题，因为还有多于半数的副本正常工作，数据库的服务不受影响。如果主副本所在服务器出现问题，其租约会得不到延续，待其租约失效后，其他从副本会通过选举协议选举出新的主副本并授予新的租约，之后即可恢复数据库的服务。

#### 均衡层

**新建表和新增分区时，系统会按照均衡原则选择合适的日志流创建 Tablet**。当租户的属性发生变更，新增了机器资源，或者经过长时间使用后，Tablet 在各台机器上不再均衡时，**均衡层通过日志流的分裂和合并操作**，并在这个过程中配合日志流副本的移动，让数据和服务在多个服务器之间**再次均衡**。

当租户有**扩容操作**，获得更多服务器资源时，均衡层会将租户内已有的**日志流进行分裂**，并**选择合适数量的 Tablet** 一同分裂到新的日志流中，再将新日志流迁移到新增的服务器上，以充分利用扩容后的资源。当租户有**缩容操作**时，均衡层会**把需要缩减的服务器上的日志流迁移到其他服务器上**，并和其他服务器上已有的日志流**进行合并**，以缩减机器的资源占用。

当数据库长期使用后，随着持续创建删除表格，并且写入更多的数据，即使没有服务器资源数量变化，原本均衡的情况可能被破坏。最常见的情况是，当用户删除了一批表格后，删除的表格可能原本聚集在某一些机器上，删除后这些机器上的 Tablet 数量就变少了，应该把其他机器的Tablet 均衡一些到这些少的机器上。**均衡层会定期生成均衡计划，将 Tablet 多的服务器上日志流分裂出临时日志流并携带需要移动的 Tablet，临时日志流迁移到目的服务器后再和目的服务器上的日志流进行合并，以达成均衡的效果。**

#### 事务层

提供修改一个分区或多个分区的原子性和隔离性

事务层保证了单个分区和多个分区 DML 操作提交的原子性，也保证了并发事务之间的多版本隔离能力。

##### 事务层-原子性

一个分区上事务的**修改通过 write-ahead log 可以保证事务提交的原子性**。事务的修改涉及多个分区时，每个分区会产生并持久化各自的 write-ahead log，事务层通过优化的**两阶段提交协议**来保证提交的原子性。

事务层会选择一个事务修改的一个分区产生**协调者状态机**，协调者会与事务修改的所有分区通信，判断 write-ahead log 是否持久化，当所有分区都完成持久化后，事务进入提交状态，协调者会再驱动所有分区写下这个事务的 Commit 日志，表示事务最终的提交状态。当从副本回放或者数据库重启时，已经完成提交的事务都会通过 Commit 日志确定各自分区事务的状态。

宕机重启场景下，宕机前还未完成的事务，会出现写完 write-ahead log 但是还没有 Commit日志的情况，**每个分区的 write-ahead log 都会包含事务的所有分区列表**，通过此信息可以重新确定哪个分区是协调者并恢复协调者的状态，再次推进两阶段状态机，直到事务最终的Commit 或 Abort 状态。

##### 事务层-隔离性

**GTS 服务是一个租户内产生连续增长的时间戳的服务**，其通过多副本保证可用性，底层机制与上面复制层所描述的分区副本同步机制是一样的。

每个事务在提交时会从 GTS 获取一个时间戳作为事务的提交版本号并持久化在分区的 writeahead log 中，事务内所有修改的数据都以此提交版本号标记。

每个语句开始时（对于 Read Committed 隔离级别）或者每个事务开始时（对于 RepeatableRead 和 Serializable 隔离级别）会从 GTS 获取一个时间戳作为语句或事务的读取版本号。在读取数据时，会跳过事务版本号比读取版本号大的数据，通过这种方式为读取操作提供了统一的全局数据快照。

#### SQL 层

将用户发起的 SQL 转化成对于存储数据的操作和处理

SQL 层将用户的 SQL 请求转化成对一个或多个分区的数据访问。

##### SQL层-SQL层组件

SQL 层处理一个请求的执行流程是：Parser、Resolver、Transformer、Optimizer、Code Generator、Executor。

**Parser 负责词法/语法解析**，Parser 会将用户的 SQL 分成一个个的“Token”，并根据预先设定好的语法规则解析整个请求，转换成语法树（Syntax Tree）。

**Resolver 负责语义解析**，将根据数据库元信息将 SQL 请求中的 Token 翻译成对应的对象（例如库、表、列、索引等），生成的数据结构叫做 Statement Tree。

**Transformer 负责逻辑改写**，根据内部的规则或代价模型，将 SQL 改写为与之等价的其他形式，并将其提供给后续的优化器做进一步的优化。Transformer 的工作方式是在原 Statement Tree 上做等价变换，变换的结果仍然是一棵 Statement Tree。

**Optimizer（优化器）为 SQL 请求生成最佳的执行计划**，需要综合考虑 SQL 请求的语义、对象数据特征、对象物理分布等多方面因素，解决访问路径选择、联接顺序选择、联接算法选择、分布式计划生成等问题，最终生成执行计划。

**Code Generator（代码生成器）将执行计划转换为可执行的代码**，但是不做任何优化选择。

**Executor（执行器）启动 SQL 的执行过程**。

在标准的 SQL 流程之外，SQL 层还有 **Plan Cache** 能力，将历史的执行计划缓存在内存中，后续的执行可以反复执行这个计划，避免了重复查询优化的过程。配合 Fast-parser 模块，仅使用词法分析对文本串直接参数化，获取参数化后的文本及常量参数，让 SQL 直接命中 Plan Cache，加速频繁执行的 SQL。

##### SQL 层-多种计划

SQL 层的执行计划分为**本地、远程和分布式**三种。

本地执行计划只访问本服务器的数据。

远程执行计划只访问非本地的一台服务器的数据。

分布式计划会访问超过一台服务器的数据，执行计划会分成多个子计划在多个服务器上执行。

SQL 层**并行化执行**能力可以将执行计划分解成多个部分，由多个执行线程执行，通过一定的调度的方式，实现执行计划的并行处理。并行化执行可以充分发挥服务器 CPU 和 IO 处理能力，缩短单个查询的响应时间。并行查询技术可以用于分布式执行计划，也可以用于本地执行计划。

#### 接入层

将用户的请求转发到合适的 OceanBase 实例上进行处理

**obproxy 是 OceanBase 数据库的接入层**，负责将用户的请求**转发到合适的 OceanBase 实例**上进行处理。

obproxy 是独立的进程实例，独立于 OceanBase 的数据库实例部署。obproxy 监听网络端口，兼容 MySQL 网络协议，支持使用 MySQL 驱动的应用直接连接 OceanBase。

obproxy 能够自动发现 OceanBase 集群的数据分布信息，对于代理的每一条 SQL 语句，会尽可能识别出语句将访问的数据，并将语句直接转发到数据所在服务器的 OceanBase 实例。

obproxy 有两种部署方式：

 一种是部署在每一个需要访问数据库的应用服务器上

 另一种是部署在与 OceanBase 相同的机器上。

第一种部署方式下，应用程序直接连接部署在同一台服务器上的 obproxy，所有的请求会由obproxy 发送到合适的 OceanBase 服务器。第二种部署方式下，需要使用网络负载均衡服务将多个 obproxy 聚合成同一个对应用提供服务的入口地址。

### OBProxy

OBProxy 作为 OceanBase 数据库专用的反向代理软件，其**核心功能是路由**，将客户端发起的数据访问请求转发到正确的 OBServer 上，并将 OBServer 的响应结果转发给客户端。

客户端通过 OBProxy 访问 OceanBase 数据库的数据链路为：

用户通过任意 Client 驱动发出请求，请求通过负载均衡组件访问到任意一台无状态的OBProxy 上，然后 OBProxy 再将用户请求转发到后端 OceanBase 集群中最佳的 OBServer上去执行。

注：OBProxy 不负责分库分表，也不作为 SQL 引擎参与执行计划的生成调度，只负责纯粹的反向代理转发

每个 OBServer 均包含完整的 SQL 引擎和存储引擎，用来负责解析用户 SQL 以生成物理执行计划并执行。分布式的 OBServer 之间通过 Paxos 协议以保证高可用性。这种架构设计中，**OBProxy 只承担基本的路由和容灾功能**，而数据库的功能全部交由 OBServer 实现。这样更加简单明确的分工可以将各组件性能做得更加极致，OceanBase 数据库整体最高也能做到近似访问单机数据库的性能。

OBProxy 支持将请求正确发送至主副本，并且**通过特定配置还支持读写分离和备优先读**等场景。另外在 OBServer 节点发生宕机、升级或合并等状态时，可以通过黑名单机制确保用户请求可以被路由至状态正常的 OBServer上。

obproxy 能够自动发现 OceanBase 集群的数据分布信息，对于代理的每一条 SQL 语句，会尽可能识别出语句将访问的数据，并将语句直接转发到数据所在服务器的OceanBase 实例。

obproxy 有两种部署方式，一种是部署在每一个需要访问数据库的应用服务器上，另一种是部署在与 OceanBase 相同的机器上。第一种部署方式下，应用程序直接连接部署在同一台服务器上的 obproxy，所有的请求会由 obproxy 发送到合适的 OceanBase 服务器。第二种部署方式下，需要使用网络负载均衡服务将多个 obproxy 聚合成同一个对应用提供服务的入口地址。