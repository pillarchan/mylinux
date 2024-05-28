

## EFK架构方案

apps->filebeat->kafka->logstash->es->kibana/grafana

## kafka特性

1. 内存消耗低
2. 高可用
3. 多节点I/O性能可用性

## 什么是MQ

MQ的全称为"Message Queue"，即**消息队列**。消息队列是在消息传输过程中**保存消息**的容器，多用于**分布式系统之间进行通信**。

## 使用MQ的优势

### 应用解耦

app->功能模块->MQ->其它功能模块

**耦合是指两个或多个软件组件之间存在相互影响的或强或弱的关联关系**。耦合度越高，组件之间的依赖性越强，对彼此的影响就越大。高耦合的应用通常难以维护和扩展，因为修改一个组件可能会导致其他组件出现问题。**应用解耦**是指**降低**应用各个部分之间的**依赖性**，使各个部分能够相对独立地开发、维护和演化。解耦的主要目标是提高应用的灵活性、可维护性和可扩展性。

### 异步提速

是指通过使用消息队列来提高系统的处理速度。在传统的同步处理模式下，发送方需要等待接收方处理完消息之后才能继续执行后续操作。这可能会导致发送方阻塞，特别是当接收方处理速度较慢时。

而MQ的异步处理模式则允许发送方将消息发送到消息队列后立即返回，而无需等待接收方处理。接收方可以根据自己的速度从消息队列中获取消息进行处理。这样一来，发送方和接收方就可以并行工作，从而提高系统的整体吞吐量

### 削峰填谷

MQ的削峰填谷是指利用消息队列（MQ）来平滑流量波峰，提高系统整体的处理能力。在实际应用中，MQ的削峰填谷主要有以下两种方式：  app->MQ->功能模块->MQ->其它功能模块

**1. 缓存消息**

在流量高峰期，将大量**请求消息缓存到MQ中**，然后再由下游服务按照自己的处理能力从MQ中拉取消息进行处理。这样可以避免下游服务直接被突增的流量压垮，同时也能充分利用下游服务的空闲时间进行处理，提高整体的资源利用率。

**2. 限流**

在流量高峰期，**对上游请求进行限流，只允许一定数量的请求进入MQ**。限流的方式可以是根据请求的优先级、来源等进行限流，也可以是简单的按照时间窗口进行限流。被限流的请求可以被直接丢弃，也可以放入到另一个低优先级的队列中稍后再进行处理。

## 使用MQ的劣势

系统可用性降低:
        系统引入的外部依赖越多，系统稳定性越差，一旦MQ宕机，就会对业务造成影响。那么问题自然就是如何保证MQ的高可用呢？也就是说如果MQ自身能实现服务的高可用则该问题自然就迎刃而解了。

系统复杂度提高:
    MQ的加入大大增加了系统的复杂度，以前是同步的远程调用，现在是通过MQ进行异步调用，如何保证消息不会被丢失等情况。

## 维护的级别 

GB ---> TB（如MYSQL最高64T） ---> PB ---> EB（大数据级别）

## MQ的两种模式

### 点对点模式(一对一，消费者主动拉取数据，消息收到后消息清除)

生产者将消息发送到消息队列，消费者主动去消息队列拉取消息，拉取消息后被拉取的消息先被标记为删除，过段时间才会被最终清除掉

### 发布/订阅模式(一对多，消费者消费数据之后不会清除消息)

生产者将消息发布到消息队列，订阅了该消息的消费才就去拉取数据，拉取后被拉取的消息不会被删除，当消费者需要拉取新的消息时，会根据偏移量去计算拉取

## MQ的选择

RabbitMQ:
        优点:
            消息可靠性高，功能全面。
        缺点:
            吞吐量比较低，消息积累会影响性能，erlang语言不好定制，国内相关的开发人员相对较少。
        使用场景:
            小规模场景。

Kafka:
    优点:
        吞吐量非常大，性能非常好，集群高可用。
    缺点:
        (1)维护起来比较复杂，比如数据均衡，数据迁移相对来说比较麻烦。
        (2)当leader节点数据写入成功后(只是写入了OS cache，而后由OS异步写入磁盘)，follow节点还来不及同步数据时，leader节点挂掉的情况可能会导致部分数据丢失。解决方案就是多节点写入成功后在回应客户端ACK，但这意味着会增大延迟，从而降低集群性能。
    使用场景:
        日志分析，大数据实时流的采集等。

RocketMQ:
    优点:
        高吞吐，高性能，高可用，功能全面。
    缺点:
        开源版功能不如云上版，官方文档比较简单，客户端只支持Java。
    使用场景:
        几乎全场景。

温馨提示:
    (1)目前生产环境中使用ActiveMQ的公司越来越少了，但RabbitMQ，RocketMQ，Kafka目前很多公司还在使用。
    (2)尽管RabbitMQ相比RocketMQ，Kafka性能较差，但RabbitMQ可以保证100%数据不丢失，因此由于其数据的安全性，目前该产品也赢得很多金融公司的喜爱;
    (3)kafka诞生的背景就是为大数据生态而生的，因此在大数据量的情况下，使用kafka的相对较多;
    (4)在阿里公司内部，肯定是主推RocketMQ较多，因为其将RabbitMQ和Kafka的优点基于一身，但RocketMQ开源社区的活跃度相比kafka较弱，如果想要用性能可以直接购买阿里云的SAAS产品即可;

## 业务处理

### 要如何选择MQ产品?

​    参考上面"MQ的选择"内容。

### 如何快速处理未支付订单?

​    可以使用Rocket延迟消息快速回收未支付的订单。
​    如果不用RocketMQ也可以实现，思路如下：
​        (1)我们需要使用一个专门的延迟队列来存储原始数据；
​        (2)而后使用延迟消息服务(这通常由开发团队来设计)消费该队列数据，目的是用于过滤掉未支付的订单；
​        (3)将上一步处理后的消息重新写入一个新的队列中，该队列数据交由下游的消费者进行处理;

### 如何保证下单操作与消息发送的事务一致性?

​    使用RocketMQ事务消息保证事务的一致性。其实现思路如下:
​        (1)生产者开启事物发送half数据给RocketMQ，值得注意的是，此时未接收到回滚或提交对于消费者而言是看不到这部分half数据的，但这些数据已经发送到RocketMQ服务端了;
​        (2)当RocketMQ接收到消息后，会响应生产者已接收到half数据以确保数据接收成功;
​        (3)生产者继续执行本地事务;
​        (4)生产者在执行本地事务时可以进行回滚或者提交本次事务;
​        (5)如果RocketMQ长时间未能确定该事物是否提交，会定期访问生产者进行回查;
​        (6)生产者会访问本地的事务管理，用于回查消息状态(此处我们只讨论提交会回滚两种状态);
​        (7)根据上一步查询的消息状态提交进行回滚;
​        (8)一旦数据被提交，则提交到目标topic数据是可以被消费者正常消费的;如果数据未能提交，即回滚的事物数据将直接丢弃，而这些被回滚的数据消费者永远都无法拿到，因为消费者始终只能拿到已提交的事物哟;

### 如何保证集群高可用?

​    普通的多主多从集群，在RocketMQ的conf目录下提供了现成的配置Demo。而我们的课程会主要讲解kafka高可用集群搭建。
​    Kafka使用zookeeper实现高可用，而zookeeper的Zab协议是借鉴于Paxos协议。
​    RocketMQ使用Dledger技术实现高可用，而Dledger底层使用Raft协议来进行leader选举。

### 如何平衡MQ消息的高吞吐和高可靠?

​    我们可以从生产者的发送消息；broker的主从数据同步，消息刷盘；消费者的消费消息这三种角色的四个环节来优化高吞吐和高可用的区别。

### 如何保证高性能文件读写?

​    RocketMQ文件读写高性能的三大利器：磁盘顺序写，异步刷盘，零拷贝等技术（这些kafka也支持）。
​    如下图所示，DMA的英文拼写是"Direct Memory Access"，汉语的意思就是直接内存访问，是一种不经过CPU而直接从内存存取数据的数据交换模式。 
​    温馨提示:
​        JDK NIO零拷贝实现分为两种方案，即mmap和sendFile。
​            (1)mmap比较适合小文件读写，对文件大小有限制，一般在1.5GB~2.0GB之间;
​            (2)sendFile比较适合大文件传输，可以利用DMA方式，减少CPU拷贝;

### 分布式服务消息等幂三大语义分类是什么？

​    "At Least Once"，"At Most Once"，"Exactly One"。

## kafka部署

### 单机部署

1. 官网下载二进制包

   ```
   https://kafka.apache.org/downloads
   ```

2. 解压二进制包到指定目录

3. 建立软连接

4. 配置环境变量

5. 修改配置文件

   ```
   config/server.properties中的
   broker.id=xxx
   zookeeper.connect=192.168.76.113:2181,192.168.76.112:2181,192.168.76.111:2181/kafka370
   
   这里的kafka370就是 kafka在zookeeper上的znode节点，里面将包含kafka的所有数据
   ```

6. 修改启动文件堆内存大小

   ```
   bin/kafka-server-start.sh
       export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
   默认是1个G
   ```

7. 集群部署

   ```
   至少3台同样配置的服务器，安装好kafka后修改配置文件中 broker.id，一定是不一样的值
   然后启动服务即可
   
   可修改配置文件中
   log.dirs=为自定义目录
   默认为/tmp/kafka-logs
   log.dirs就是数据存储目录
   
   如果已经存在/tmp/kafka-logs/meta.properties
   须注意：
   cluster.id 是否一致
   broker.id 是否与配置文件中的broker.id一致
   ```

8. 访问集群

   ```
   kafka-topics.sh --bootstrap-server ip:port,ip:port,ip:port[,ip:port...] --list
   如：kafka-topics.sh --bootstrap-server 192.168.76.114:9092,192.168.76.115:9092,192.168.76.116:9092 --list
   ```

## Kafka基础管理命令

### 启动服务

```
kafka-server-start.sh [-daemon] server.properties [--override property=value]*
```

启动生产者

```
kafka-console-producer.sh --topic <String> --bootstrap-server ip:port
```

启动消费者

```
kafka-console-cosumer.sh --topic <String> --bootstrap-server ip:port [--from-beginning]
```

topic的增删改查

```
kafka-topics.sh --bootstrap-server ip:port --list
kafka-topics.sh --bootstrap-server ip:port --topic <String> --describe
kafka-topics.sh --bootstrap-server ip:port --topic <String> --create --partitions <Num> --replication-factor <Num>
kafka-topics.sh --bootstrap-server ip:port --topic <String> --alter --partitions <Num>
```

## Kafka基础架构

kafka集群 kafka cluster也叫broker list 分为实例节点，用不同的broker.id区分，它们都依赖于zookeeper提供元数据的存储

外部连接包括有 生产者，消费者，管理API，流处理工具，数据库连接器

### 生产者

生产者通过API或脚本基于topic将数据写入集群

### topic数据

topic数据就存储在配置文件中logs.dir目录里，其中topic名的构成就是topic主题名-partition编号组成

topic数据包括有 topic主题名 id 分区 副本数 配置，当指定了分区数和副本数，一个topic数据就会按分区和副本分别存储到所分配的分区和副本中，其中leader为读写节点，存储的位置在配置文件中logs.dir目录下对应topic目录下，包括索引、日志、元数据、时间索引、检查点

```
Topic: lala	TopicId: FOCb5jseRbS2HJTFo8OiLQ	PartitionCount: 3	ReplicationFactor: 2	Configs: 
	Topic: lala	Partition: 0	Leader: 116	Replicas: 116,115	Isr: 116,115
	Topic: lala	Partition: 1	Leader: 115	Replicas: 115,114	Isr: 115,114
	Topic: lala	Partition: 2	Leader: 114	Replicas: 114,116	Isr: 114,116
	topic主题名  分区编号        读定节点      副本存放节点为的编号
```

#### 分区

​	可以将数据均衡地分布在不同的节点上，降低磁盘占用率，充分利用集群提升I/O性能，网络性能

#### 副本

​	不同的分区数据可以进行主从复制，同步数据，如果主副本的节点故障了，还可以读写从副本，达到高可用的目的。但是从副本一般只能同步数据，外部不能直接读写数据

注意：

kafka中的读写都是基于leader的

### 消费者

​	消费者是去kafka集群拉取数据

### 消费者组

当生产者发送的数据过多，而单个消费者无法即时消费完就会造成延迟，这时，就需要考虑使用消费者组来共同消费生产者发送的数据。

当消费者组中一个消费者在消费一个partition中leader的数据时，其它的消费者是不能来进行访问，即消费者不能同时消费同一partition中leader的数据

### 小节

### Producer:

消息生产者，就是向kafka broker发消息的客户端。

### Consumer:

消息消费者，向kafka broker拉取消息的客户端。

### Consumer Group(简称"CG"):

消费者组，由多个consumer组成。消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个组内消费者消费，消费者组之间互不影响。
所有的消费者都属于某个消费者组，即消费者组是逻辑上的一个订阅者。

### Broker:

一台kafka服务器就是一个broker，一个集群由多个broker组成。一个broker可以容纳多个topic。

### Topic:

可以理解为一个队列，生产者和消费者面向的都是一个topic。

### Parition:

为了实现扩展性，一个非常大的topic可以分不到多个broker(即服务器)上，一个topic可以分为多个pairtition，每个partition是一个有序的队列。

### Replica:

副本，为保证集群中的某个节点发生故障时，该节点上的partition数据不丢失，且kafka仍然能够继续工作，kafka提供了副本机制，一个topic的每个分区都有若干个副本，一个leader和若干个follower。

#### 	leader:

每个分区多个副本为"主"，生产者发送数据的对象，以及消费者消费数据的对象都是leader。

#### 	follower:

每个分区多个副本中的"从"，实时从leader中同步数据，保持和leader数据的同步。leader发生故障时，某个follower会成为新的leader。

温馨提示:
    (1)kafka中消息是以topic进行分类的，生产者生产消息，消费者消费消息，都是面向topic的。
    (2)topic是逻辑上的概念，而partition是物理上的概念，每个paritition对应于一个log文件，该log文件中存储的就是producer生产的数据;
    (3)producer生产的数据会被不断追加到该log文件末尾，且每条数据都有自己的offset；
    (4)消费者组中的每个消费者，都会实时记录自己消费到了哪个offset，以便出错恢复时，从上次的位置继续消费;

